import os
import traceback
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()

os.environ.get(
    'DEBTOR_DATABASE_URL'
)

from debtorapp import app as da


def run_step(results, name, func):
    try:
        func()
        results.append((name, 'PASS', ''))
    except Exception as exc:
        results.append((name, 'FAIL', f'{type(exc).__name__}: {exc}'))
        traceback.print_exc()


def scalar(cursor, sql, params=()):
    cursor.execute(sql, params)
    row = cursor.fetchone()
    return row[0] if row else None


def main():
    results = []
    stamp = datetime.now().strftime('%Y%m%d%H%M%S')
    conn = da.sqlite3.connect(da.DB_PATH)
    conn.row_factory = da.sqlite3.Row
    cursor = conn.cursor()

    try:
        def meta_save():
            da.set_app_meta(cursor, f'smoke_meta_{stamp}', 'ok')
            assert da.get_app_meta(cursor, f'smoke_meta_{stamp}') == 'ok'

        def client_master_crud():
            name = f'ZZ Smoke Client {stamp}'
            cursor.execute(
                '''
                INSERT INTO client_master
                    (client_name, phone, email, gstin, client_group, crp_of_group, reffered_by, whatapp_group, client_category)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                ''',
                (name, '9999999999', 'smoke@example.com', 'GSTSMOKE', 'Smoke Group', 'Smoke CRP', 'Smoke Ref', 'Smoke WA', 'Private'),
            )
            client_id = cursor.lastrowid
            assert client_id
            cursor.execute('UPDATE client_master SET phone = ? WHERE id = ?', ('8888888888', client_id))
            assert scalar(cursor, 'SELECT phone FROM client_master WHERE id = ?', (client_id,)) == '8888888888'
            cursor.execute('DELETE FROM client_master WHERE id = ?', (client_id,))
            assert scalar(cursor, 'SELECT COUNT(*) FROM client_master WHERE id = ?', (client_id,)) == 0

        def group_crp_firm_partner_crud():
            group = f'ZZ Smoke Group {stamp}'
            crp = f'ZZ Smoke CRP {stamp}'
            firm = f'ZZ Smoke Firm {stamp}'
            partner = f'ZZ Smoke Partner {stamp}'

            cursor.execute('INSERT INTO client_group_master (group_name, crp_name, reffered_by, updated_at) VALUES (?, ?, ?, ?)', (group, crp, 'Smoke Ref', da.datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
            group_id = cursor.lastrowid
            cursor.execute('UPDATE client_group_master SET reffered_by = ? WHERE id = ?', ('Smoke Ref Updated', group_id))
            assert scalar(cursor, 'SELECT reffered_by FROM client_group_master WHERE id = ?', (group_id,)) == 'Smoke Ref Updated'
            cursor.execute('DELETE FROM client_group_master WHERE id = ?', (group_id,))

            cursor.execute('INSERT INTO crp_master (crp_name, updated_at) VALUES (?, ?)', (crp, da.datetime.now().strftime('%Y-%m-%d %H:%M:%S')))
            crp_id = cursor.lastrowid
            cursor.execute('UPDATE crp_master SET crp_name = ? WHERE id = ?', (crp + ' Updated', crp_id))
            assert scalar(cursor, 'SELECT crp_name FROM crp_master WHERE id = ?', (crp_id,)) == crp + ' Updated'
            cursor.execute('DELETE FROM crp_master WHERE id = ?', (crp_id,))

            cursor.execute('INSERT INTO firm_master (firm_name, short_name) VALUES (?, ?)', (firm, 'ZZS'))
            firm_id = cursor.lastrowid
            cursor.execute('UPDATE firm_master SET short_name = ? WHERE id = ?', ('ZZU', firm_id))
            assert scalar(cursor, 'SELECT short_name FROM firm_master WHERE id = ?', (firm_id,)) == 'ZZU'
            cursor.execute('DELETE FROM firm_master WHERE id = ?', (firm_id,))

            cursor.execute('INSERT INTO executive_partner_master (partner_name, final_ep) VALUES (?, ?)', (partner, 'ZZ EP'))
            partner_id = cursor.lastrowid
            cursor.execute('UPDATE executive_partner_master SET final_ep = ? WHERE id = ?', ('ZZ EP Updated', partner_id))
            assert scalar(cursor, 'SELECT final_ep FROM executive_partner_master WHERE id = ?', (partner_id,)) == 'ZZ EP Updated'
            cursor.execute('DELETE FROM executive_partner_master WHERE id = ?', (partner_id,))

        def billing_add_update_soft_delete():
            firm_name = scalar(cursor, 'SELECT firm_name FROM firm_master ORDER BY id LIMIT 1') or 'Smoke Firm'
            inserted = da.insert_billing_row(
                cursor,
                firm_name,
                da.parse_input_date('2026-06-15'),
                f'SMOKE/{stamp}',
                f'ZZ Smoke Party {stamp}',
                1234.0,
            )
            assert inserted
            row_id = cursor.lastrowid
            assert row_id
            cursor.execute('UPDATE billing_report SET amount = ?, group_override = ? WHERE id = ?', (1200.0, 'Smoke Group', row_id))
            assert float(scalar(cursor, 'SELECT amount FROM billing_report WHERE id = ?', (row_id,))) == 1200.0
            with da.app.test_request_context('/smoke-test'):
                deleted_count = da.soft_delete_billing_rows(cursor, [row_id], 'Smoke delete')
                assert deleted_count == 1
            assert scalar(cursor, 'SELECT deleted_at IS NOT NULL FROM billing_report WHERE id = ?', (row_id,))

        def receipt_and_adjustment_post():
            rows = da.get_report_rows(cursor)
            row = next(item for item in rows if float(item.get('amount') or 0) > 10)
            bill_id = row['id']
            before_amount = float(row.get('amount') or 0)
            da.post_receipt_rows(
                cursor,
                [{'row_id': bill_id, 'received_amount': 1}],
                'Cash',
                '2026-06-15',
                da.datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            )
            assert scalar(cursor, 'SELECT COUNT(*) FROM receipt_register WHERE source_bill_id = ?', (bill_id,)) >= 1
            after_receipt_amount = float(scalar(cursor, 'SELECT amount FROM billing_report WHERE id = ?', (bill_id,)))
            assert round(after_receipt_amount, 2) == round(before_amount - 1, 2)

            rows = da.get_report_rows(cursor)
            row = next(item for item in rows if float(item.get('amount') or 0) > 10)
            bill_id = row['id']
            before_adjustment_amount = float(row.get('amount') or 0)
            da.post_adjustment_rows(
                cursor,
                [{'row_id': bill_id, 'received_amount': 1}],
                'Discount',
                '2026-06-15',
                da.datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            )
            assert scalar(cursor, 'SELECT COUNT(*) FROM receipt_adjustment_register WHERE source_bill_id = ?', (bill_id,)) >= 1
            after_adjustment_amount = float(scalar(cursor, 'SELECT amount FROM billing_report WHERE id = ?', (bill_id,)))
            assert round(after_adjustment_amount, 2) == round(before_adjustment_amount - 1, 2)

        def read_queries_and_seeds():
            da.ensure_debtor_nav_access_table(cursor)
            da.ensure_deleted_records_log_table(cursor)
            da.ensure_receipt_register_tally_columns(cursor)
            da.ensure_cheque_bounce_register_table(cursor)
            assert len(da.get_report_rows(cursor)) >= 0
            cursor.execute('SELECT COUNT(*) FROM receipt_register')
            cursor.fetchone()
            cursor.execute('SELECT COUNT(*) FROM deleted_records_log')
            cursor.fetchone()

        for name, func in [
            ('app_meta save/read', meta_save),
            ('client_master create/update/delete', client_master_crud),
            ('group/crp/firm/partner create/update/delete', group_crp_firm_partner_crud),
            ('billing_report add/update/soft-delete', billing_add_update_soft_delete),
            ('receipt and adjustment save', receipt_and_adjustment_post),
            ('read queries and seed helpers', read_queries_and_seeds),
        ]:
            run_step(results, name, func)
    finally:
        conn.rollback()
        conn.close()

    print('Debtorapp PostgreSQL smoke test (rollback-only)')
    failed = False
    for name, status, detail in results:
        print(f'{status}: {name}' + (f' -> {detail}' if detail else ''))
        failed = failed or status == 'FAIL'
    raise SystemExit(1 if failed else 0)


if __name__ == '__main__':
    main()
