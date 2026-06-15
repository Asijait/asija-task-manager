import argparse
import os
import sqlite3
import sys


BASE_DIR = os.path.dirname(os.path.abspath(__file__))
SQLITE_DB_PATH = os.path.join(BASE_DIR, 'database.db')


def parse_args():
    parser = argparse.ArgumentParser(description='Migrate debtorapp database.db data to PostgreSQL.')
    parser.add_argument(
        '--sqlite-db',
        default=SQLITE_DB_PATH,
        help='Path to source SQLite database. Default: debtorapp/database.db',
    )
    parser.add_argument(
        '--database-url',
        default=os.environ.get('DEBTOR_DATABASE_URL') or os.environ.get('DATABASE_URL'),
        help='PostgreSQL URL, for example postgresql://user:password@localhost:5432/debtorapp',
    )
    parser.add_argument(
        '--truncate',
        action='store_true',
        help='Delete PostgreSQL table data before copying from SQLite.',
    )
    return parser.parse_args()


def load_sqlite_tables(sqlite_db_path):
    source = sqlite3.connect(sqlite_db_path)
    source.row_factory = sqlite3.Row
    tables = [
        row['name']
        for row in source.execute(
            """
            SELECT name
            FROM sqlite_master
            WHERE type = 'table'
              AND name NOT LIKE 'sqlite_%'
            ORDER BY name
            """
        )
    ]
    return source, tables


def init_postgres_schema(database_url):
    os.environ['DEBTOR_DATABASE_URL'] = database_url
    sys.path.insert(0, BASE_DIR)
    import app as debtor_app

    debtor_app.init_db()


def copy_table(source, target, table_name, truncate=False):
    source_columns = [
        row['name']
        for row in source.execute(f'PRAGMA table_info("{table_name}")').fetchall()
    ]
    if not source_columns:
        return 0

    with target.cursor() as cursor:
        cursor.execute(
            """
            SELECT column_name
            FROM information_schema.columns
            WHERE table_schema = current_schema()
              AND table_name = %s
            ORDER BY ordinal_position
            """,
            (table_name,),
        )
        target_columns = [row[0] for row in cursor.fetchall()]

    columns = [column for column in source_columns if column in target_columns]
    if not columns:
        return 0

    if truncate:
        with target.cursor() as cursor:
            cursor.execute(f'TRUNCATE TABLE "{table_name}" RESTART IDENTITY CASCADE')

    rows = source.execute(
        f'SELECT {", ".join(quote_sqlite_identifier(column) for column in columns)} FROM "{table_name}"'
    ).fetchall()
    if not rows:
        return 0

    column_list = ', '.join(f'"{column}"' for column in columns)
    placeholders = ', '.join(['%s'] * len(columns))
    insert_sql = f'INSERT INTO "{table_name}" ({column_list}) VALUES ({placeholders}) ON CONFLICT DO NOTHING'
    values = [tuple(row[column] for column in columns) for row in rows]

    with target.cursor() as cursor:
        cursor.executemany(insert_sql, values)
    reset_serial(target, table_name)
    return len(rows)


def reset_serial(target, table_name):
    with target.cursor() as cursor:
        cursor.execute(
            """
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = current_schema()
              AND table_name = %s
              AND column_name = 'id'
            """,
            (table_name,),
        )
        if cursor.fetchone() is None:
            return
        cursor.execute("SELECT pg_get_serial_sequence(%s, 'id')", (table_name,))
        row = cursor.fetchone()
        sequence_name = row[0] if row else None
        if not sequence_name:
            return
        cursor.execute(f'SELECT COALESCE(MAX(id), 0) FROM "{table_name}"')
        max_id = cursor.fetchone()[0]
        cursor.execute('SELECT setval(%s, %s, %s)', (sequence_name, max_id, max_id > 0))


def quote_sqlite_identifier(identifier):
    return '"' + identifier.replace('"', '""') + '"'


def main():
    args = parse_args()
    if not args.database_url:
        raise SystemExit('Please pass --database-url or set DEBTOR_DATABASE_URL.')
    if not os.path.exists(args.sqlite_db):
        raise SystemExit(f'SQLite database not found: {args.sqlite_db}')

    try:
        import psycopg2
    except ImportError as exc:
        raise SystemExit('Install PostgreSQL driver first: python -m pip install psycopg2-binary') from exc

    init_postgres_schema(args.database_url)
    source, tables = load_sqlite_tables(args.sqlite_db)
    target = psycopg2.connect(args.database_url)
    try:
        copied = {}
        for table_name in tables:
            copied[table_name] = copy_table(source, target, table_name, truncate=args.truncate)
        target.commit()
    except Exception:
        target.rollback()
        raise
    finally:
        source.close()
        target.close()

    print('Migration complete.')
    for table_name, count in copied.items():
        print(f'{table_name}: {count} rows')


if __name__ == '__main__':
    main()
