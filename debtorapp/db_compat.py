import os
import re
import sqlite3 as _sqlite3

try:
    import psycopg2
    import psycopg2.extras
    import psycopg2.errors
except ImportError:  # PostgreSQL mode will raise a clear error at connect time.
    psycopg2 = None


DEBTOR_DATABASE_URL = os.environ.get('DEBTOR_DATABASE_URL') or os.environ.get('DATABASE_URL')
DEBTOR_SQLITE_PATH = os.path.abspath(
    os.environ.get('DEBTOR_SQLITE_PATH') or os.path.join(os.path.dirname(__file__), 'database.db')
)


Error = _sqlite3.Error
OperationalError = _sqlite3.OperationalError
IntegrityError = _sqlite3.IntegrityError


class PgRow:
    def __init__(self, data, columns=None):
        if isinstance(data, dict):
            self._data = dict(data)
            self._columns = list(data.keys())
        else:
            self._columns = list(columns or [])
            self._data = dict(zip(self._columns, data))

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

    def __contains__(self, key):
        return key in self._data


class _RowMeta(type):
    def __instancecheck__(cls, instance):
        return isinstance(instance, (_sqlite3.Row, PgRow))


class Row(metaclass=_RowMeta):
    def __new__(cls, cursor, row):
        return _sqlite3.Row(cursor, row)


def use_postgres(database=None):
    if not DEBTOR_DATABASE_URL:
        return False
    if database in (None, ''):
        return True
    try:
        return os.path.abspath(database) == DEBTOR_SQLITE_PATH
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
        raw = psycopg2.connect(DEBTOR_DATABASE_URL)
        raw.autocommit = False
        return PgConnection(raw)
    except Exception as exc:
        raise OperationalError(str(exc)) from exc


class PgConnection:
    def __init__(self, raw):
        self.raw = raw
        self.row_factory = None

    def cursor(self):
        return PgCursor(self.raw.cursor(cursor_factory=psycopg2.extras.RealDictCursor), self.raw)

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
        self._lastrowid = None
        self._buffer = None

    @property
    def lastrowid(self):
        return self._lastrowid

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
                self._buffer = load_table_info(self.connection, translated.table_name)
                self._lastrowid = None
                return self
            self.raw.execute(translated, params)
            self._update_lastrowid(translated)
            return self
        except Exception as exc:
            self._rollback_failed_statement()
            mapped = _map_exception(exc)
            raise mapped(str(exc)) from exc

    def executemany(self, sql, seq_of_params):
        translated = translate_sql(sql)
        try:
            self.raw.executemany(translated, seq_of_params)
            self._lastrowid = None
            return self
        except Exception as exc:
            self._rollback_failed_statement()
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

    def _update_lastrowid(self, sql):
        self._lastrowid = None
        match = re.match(r'\s*INSERT\s+INTO\s+"?([A-Za-z_][A-Za-z0-9_]*)"?\b', sql, re.IGNORECASE)
        if not match or re.search(r'\bON\s+CONFLICT\b', sql, re.IGNORECASE):
            return
        table_name = match.group(1)
        try:
            with self.connection.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cursor:
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
                    self._lastrowid = id_row['id'] if id_row else None
        except Exception:
            self._rollback_failed_statement()
            self._lastrowid = None

    def _rollback_failed_statement(self):
        try:
            if self.connection.get_transaction_status() == psycopg2.extensions.TRANSACTION_STATUS_INERROR:
                self.connection.rollback()
        except Exception:
            pass


class TableInfoQuery:
    def __init__(self, table_name):
        self.table_name = table_name


def translate_sql(sql):
    compact = sql.strip()
    pragma_match = re.match(r'PRAGMA\s+table_info\(([^)]+)\)', compact, re.IGNORECASE)
    if pragma_match:
        return TableInfoQuery(pragma_match.group(1).strip().strip('"\''))
    if re.match(r'PRAGMA\s+(busy_timeout|journal_mode)\b', compact, re.IGNORECASE):
        return 'SELECT 1'

    sql = re.sub(r'INTEGER\s+PRIMARY\s+KEY\s+AUTOINCREMENT', 'SERIAL PRIMARY KEY', sql, flags=re.IGNORECASE)
    sql = re.sub(r'\s+COLLATE\s+NOCASE\b', '', sql, flags=re.IGNORECASE)
    sql = re.sub(r'\bINSERT\s+OR\s+IGNORE\s+INTO\b', 'INSERT INTO', sql, flags=re.IGNORECASE)
    if re.match(r'\s*INSERT\s+INTO\b', sql, re.IGNORECASE) and 'ON CONFLICT' not in sql.upper():
        if 'INSERT OR IGNORE' in compact.upper():
            sql = sql.rstrip().rstrip(';') + ' ON CONFLICT DO NOTHING'
    sql = sql.replace("date(bill_date, '+30 days')", "(CAST(bill_date AS date) + INTERVAL '30 days')")
    sql = re.sub(r'\bdate\((posted_at)\)', r'CAST(\1 AS date)', sql, flags=re.IGNORECASE)
    sql = sql.replace(
        "GROUP_CONCAT(DISTINCT COALESCE(NULLIF(billing_report.short_name, ''), billing_report.firm_name))",
        "STRING_AGG(DISTINCT COALESCE(NULLIF(billing_report.short_name, ''), billing_report.firm_name)::text, ', ')",
    )
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
