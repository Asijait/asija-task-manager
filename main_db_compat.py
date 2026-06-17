import os
import re
import sqlite3 as _sqlite3

try:
    from dotenv import load_dotenv
except ImportError:
    def load_dotenv(path=None):
        env_path = path or os.path.join(os.path.dirname(__file__), '.env')
        if not os.path.exists(env_path):
            return False
        with open(env_path, 'r', encoding='utf-8') as env_file:
            for line in env_file:
                line = line.strip()
                if not line or line.startswith('#') or '=' not in line:
                    continue
                key, value = line.split('=', 1)
                os.environ.setdefault(key.strip(), value.strip().strip('"').strip("'"))
        return True

try:
    import psycopg2
    import psycopg2.extras
except ImportError:
    psycopg2 = None

load_dotenv()

APP_DATABASE_URL = os.environ.get('APP_DATABASE_URL')
APP_SQLITE_PATH = os.path.abspath(
    os.environ.get('APP_SQLITE_PATH') or os.path.join(os.path.dirname(__file__), 'tasks.db')
)


Error = _sqlite3.Error
OperationalError = _sqlite3.OperationalError
IntegrityError = _sqlite3.IntegrityError
Row = _sqlite3.Row


class PgRow:
    def __init__(self, data):
        self._data = dict(data)
        self._columns = list(self._data.keys())

    def __getitem__(self, key):
        if isinstance(key, int):
            return self._data[self._columns[key]]
        return self._data[key]

    def get(self, key, default=None):
        return self._data.get(key, default)

    def keys(self):
        return self._columns

    def items(self):
        return self._data.items()

    def __iter__(self):
        for key in self._columns:
            yield self._data[key]

    def __len__(self):
        return len(self._columns)


def use_postgres(database=None):
    if not APP_DATABASE_URL:
        return False
    if database in (None, ''):
        return True
    try:
        return os.path.abspath(database) == APP_SQLITE_PATH
    except TypeError:
        return False


def connect(database=None, *args, **kwargs):
    if not use_postgres(database):
        return _sqlite3.connect(database, *args, **kwargs)
    if psycopg2 is None:
        raise OperationalError(
            'PostgreSQL mode requires psycopg2-binary. Install it with: '
            'python -m pip install psycopg2-binary'
        )
    try:
        raw = psycopg2.connect(APP_DATABASE_URL)
        raw.autocommit = False
        return PgConnection(raw)
    except Exception as exc:
        raise OperationalError(str(exc)) from exc


class PgConnection:
    def __init__(self, raw):
        self.raw = raw
        self.row_factory = None
        self._last_insert_id = None

    def cursor(self):
        return PgCursor(self.raw.cursor(cursor_factory=psycopg2.extras.RealDictCursor), self)

    def execute(self, sql, params=None):
        cursor = self.cursor()
        cursor.execute(sql, params)
        return cursor

    def commit(self):
        self.raw.commit()

    def rollback(self):
        self.raw.rollback()

    def close(self):
        self.raw.close()

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc, tb):
        if exc_type:
            self.rollback()
        else:
            self.commit()
        self.close()


class PgCursor:
    def __init__(self, raw, connection):
        self.raw = raw
        self.connection = connection
        self._buffer = None

    @property
    def rowcount(self):
        if self._buffer is not None:
            return len(self._buffer)
        return self.raw.rowcount

    def execute(self, sql, params=None):
        self._buffer = None
        translated = translate_sql(sql)
        try:
            if isinstance(translated, TableInfoQuery):
                self._buffer = load_table_info(self.connection.raw, translated.table_name)
                return self
            if isinstance(translated, LastInsertIdQuery):
                self._buffer = [PgRow({'last_insert_rowid()': self.connection._last_insert_id or 0})]
                return self
            self.raw.execute(translated, params)
            self._update_last_insert_id(translated)
            return self
        except Exception as exc:
            mapped = _map_exception(exc)
            raise mapped(str(exc)) from exc

    def executemany(self, sql, seq_of_params):
        translated = translate_sql(sql)
        try:
            self.raw.executemany(translated, seq_of_params)
            self.connection._last_insert_id = None
            return self
        except Exception as exc:
            mapped = _map_exception(exc)
            raise mapped(str(exc)) from exc

    def fetchone(self):
        if self._buffer is not None:
            if not self._buffer:
                return None
            return self._buffer.pop(0)
        row = self.raw.fetchone()
        return PgRow(row) if row is not None else None

    def fetchall(self):
        if self._buffer is not None:
            rows = self._buffer
            self._buffer = []
            return rows
        return [PgRow(row) for row in self.raw.fetchall()]

    def close(self):
        self.raw.close()

    def _update_last_insert_id(self, sql):
        self.connection._last_insert_id = None
        match = re.match(r'\s*INSERT\s+INTO\s+"?([A-Za-z_][A-Za-z0-9_]*)"?\b', sql, re.IGNORECASE)
        if not match or re.search(r'\bON\s+CONFLICT\b', sql, re.IGNORECASE):
            return
        table_name = match.group(1)
        try:
            with self.connection.raw.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cursor:
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
                cursor.execute("SELECT pg_get_serial_sequence(%s, 'id') AS seq", (table_name,))
                row = cursor.fetchone()
                sequence_name = row['seq'] if row and row.get('seq') else None
                if sequence_name:
                    cursor.execute('SELECT currval(%s) AS id', (sequence_name,))
                    id_row = cursor.fetchone()
                    self.connection._last_insert_id = id_row['id'] if id_row else None
        except Exception:
            self.connection.rollback()
            self.connection._last_insert_id = None


class TableInfoQuery:
    def __init__(self, table_name):
        self.table_name = table_name


class LastInsertIdQuery:
    pass


def translate_sql(sql):
    compact = sql.strip()
    if re.match(r'SELECT\s+last_insert_rowid\(\)', compact, re.IGNORECASE):
        return LastInsertIdQuery()
    pragma_match = re.match(r'PRAGMA\s+table_info\(([^)]+)\)', compact, re.IGNORECASE)
    if pragma_match:
        return TableInfoQuery(pragma_match.group(1).strip().strip('"\''))
    if re.match(r'PRAGMA\s+(busy_timeout|journal_mode|synchronous)\b', compact, re.IGNORECASE):
        return 'SELECT 1'

    had_insert_or_ignore = bool(re.match(r'\s*INSERT\s+OR\s+IGNORE\s+INTO\b', sql, re.IGNORECASE))
    sql = re.sub(r'INTEGER\s+PRIMARY\s+KEY\s+AUTOINCREMENT', 'SERIAL PRIMARY KEY', sql, flags=re.IGNORECASE)
    sql = re.sub(r'\bINSERT\s+OR\s+IGNORE\s+INTO\b', 'INSERT INTO', sql, flags=re.IGNORECASE)
    if had_insert_or_ignore and 'ON CONFLICT' not in sql.upper():
        sql = sql.rstrip().rstrip(';') + ' ON CONFLICT DO NOTHING'
    return sql.replace('?', '%s')


def load_table_info(connection, table_name):
    with connection.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cursor:
        cursor.execute(
            """
            SELECT
                c.column_name,
                c.data_type,
                c.is_nullable,
                c.column_default,
                CASE WHEN pk.column_name IS NULL THEN 0 ELSE 1 END AS is_pk
            FROM information_schema.columns c
            LEFT JOIN (
                SELECT kcu.column_name
                FROM information_schema.table_constraints tc
                JOIN information_schema.key_column_usage kcu
                  ON tc.constraint_name = kcu.constraint_name
                 AND tc.table_schema = kcu.table_schema
                WHERE tc.constraint_type = 'PRIMARY KEY'
                  AND tc.table_schema = current_schema()
                  AND tc.table_name = %s
            ) pk ON pk.column_name = c.column_name
            WHERE c.table_schema = current_schema()
              AND c.table_name = %s
            ORDER BY c.ordinal_position
            """,
            (table_name, table_name),
        )
        rows = []
        for index, row in enumerate(cursor.fetchall()):
            rows.append(PgRow({
                'cid': index,
                'name': row['column_name'],
                'type': row['data_type'],
                'notnull': 1 if row['is_nullable'] == 'NO' else 0,
                'dflt_value': row['column_default'],
                'pk': row['is_pk'],
            }))
        return rows


def _map_exception(exc):
    if psycopg2 is None:
        return Error
    if isinstance(exc, psycopg2.IntegrityError):
        return IntegrityError
    if isinstance(exc, psycopg2.OperationalError):
        return OperationalError
    return Error
