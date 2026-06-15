import argparse
import os
import sqlite3
import sys


BASE_DIR = os.path.dirname(os.path.abspath(__file__))
SQLITE_DB_PATH = os.path.join(BASE_DIR, 'tasks.db')
TABLE_COPY_ORDER = [
    'users',
    'assignee_master',
    'work_master',
    'work_assigned',
    'user_roles',
    'user_permissions',
    'work_skipped_dates',
    'work_change_requests',
]


def parse_args():
    parser = argparse.ArgumentParser(description='Migrate main app tasks.db data to PostgreSQL.')
    parser.add_argument(
        '--sqlite-db',
        default=SQLITE_DB_PATH,
        help='Path to source SQLite database. Default: tasks.db',
    )
    parser.add_argument(
        '--database-url',
        default=os.environ.get('APP_DATABASE_URL'),
        help='PostgreSQL URL, for example postgresql://user:password@localhost:5432/asijaapp',
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
    ordered_tables = [table for table in TABLE_COPY_ORDER if table in tables]
    ordered_tables.extend(table for table in tables if table not in ordered_tables)
    return source, ordered_tables


def init_postgres_schema(database_url):
    os.environ['APP_DATABASE_URL'] = database_url
    sys.path.insert(0, BASE_DIR)
    import app

    app.init_db()


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

    rows = source.execute(
        f'SELECT {", ".join(quote_identifier(column) for column in columns)} FROM "{table_name}"'
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


def truncate_tables(target, tables):
    if not tables:
        return
    table_list = ', '.join(f'"{table}"' for table in tables)
    with target.cursor() as cursor:
        cursor.execute(f'TRUNCATE TABLE {table_list} RESTART IDENTITY CASCADE')


def ensure_missing_reference_rows(source, target):
    missing_user_ids = set()
    user_refs = [
        ('user_permissions', 'user_id'),
        ('user_roles', 'user_id'),
        ('work_master', 'assigned_user_id'),
        ('work_master', 'deleted_by_user_id'),
        ('work_master', 'deleted_hidden_by_user_id'),
        ('work_change_requests', 'requester_user_id'),
        ('work_change_requests', 'reviewer_user_id'),
    ]
    existing_users = {
        row['id']
        for row in source.execute('SELECT id FROM users').fetchall()
    }
    for table_name, column_name in user_refs:
        if not sqlite_column_exists(source, table_name, column_name):
            continue
        for row in source.execute(
            f'SELECT DISTINCT "{column_name}" AS ref_id FROM "{table_name}" WHERE "{column_name}" IS NOT NULL'
        ):
            if row['ref_id'] not in existing_users:
                missing_user_ids.add(row['ref_id'])

    missing_assignee_ids = set()
    assignee_refs = [
        ('user_roles', 'assignee_id'),
        ('work_master', 'assignee_id'),
        ('work_assigned', 'assignee_id'),
    ]
    existing_assignees = {
        row['id']
        for row in source.execute('SELECT id FROM assignee_master').fetchall()
    }
    for table_name, column_name in assignee_refs:
        if not sqlite_column_exists(source, table_name, column_name):
            continue
        for row in source.execute(
            f'SELECT DISTINCT "{column_name}" AS ref_id FROM "{table_name}" WHERE "{column_name}" IS NOT NULL'
        ):
            if row['ref_id'] not in existing_assignees:
                missing_assignee_ids.add(row['ref_id'])

    with target.cursor() as cursor:
        for user_id in sorted(missing_user_ids):
            cursor.execute(
                """
                INSERT INTO users (id, email, password)
                VALUES (%s, %s, %s)
                ON CONFLICT DO NOTHING
                """,
                (user_id, f'migrated_deleted_user_{user_id}@local', 'migrated-disabled'),
            )
        for assignee_id in sorted(missing_assignee_ids):
            cursor.execute(
                """
                INSERT INTO assignee_master (id, name, email)
                VALUES (%s, %s, %s)
                ON CONFLICT DO NOTHING
                """,
                (assignee_id, f'Migrated Deleted Assignee {assignee_id}', ''),
            )
    reset_serial(target, 'users')
    reset_serial(target, 'assignee_master')


def sqlite_column_exists(source, table_name, column_name):
    try:
        columns = [row['name'] for row in source.execute(f'PRAGMA table_info("{table_name}")').fetchall()]
    except sqlite3.Error:
        return False
    return column_name in columns


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


def quote_identifier(identifier):
    return '"' + identifier.replace('"', '""') + '"'


def main():
    args = parse_args()
    if not args.database_url:
        raise SystemExit('Please pass --database-url or set APP_DATABASE_URL.')
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
        if args.truncate:
            truncate_tables(target, tables)
        copied = {}
        for table_name in tables:
            copied[table_name] = copy_table(source, target, table_name)
            if table_name == 'assignee_master':
                ensure_missing_reference_rows(source, target)
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
