import datetime as dt
import io
import os
import tempfile
import zipfile

from flask import Blueprint, jsonify, render_template, request, send_file

from .tally_sales_register_app import (
    TallyError,
    build_billwise_debtor_workbook,
    build_combined_workbook,
    build_cost_centre_breakup_workbook,
    dump_native_cost_centre_xml,
    get_billwise_debtor_rows,
    get_cost_centre_breakup,
    get_cost_centre_names,
    get_open_companies,
    get_sales_vouchers,
)


tally_connect_bp = Blueprint(
    "tally_connect",
    __name__,
    template_folder="templates",
    static_folder="static",
    url_prefix="/tally-connect",
)

REPORTS = {
    "sales": {
        "filename": "Combined_Sales_Register.xlsx",
        "mimetype": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    },
    "debtor": {
        "filename": "Bill_Wise_Debtor_Report.xlsx",
        "mimetype": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    },
    "cost-centre": {
        "filename": "Cost_Centre_Breakup.xlsx",
        "mimetype": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    },
    "debug-xml": {
        "filename": "Tally_Debug_XML.zip",
        "mimetype": "application/zip",
    },
}


def _financial_year_dates():
    today = dt.date.today()
    start_year = today.year if today.month >= 4 else today.year - 1
    return dt.date(start_year, 4, 1), today


def _request_values():
    payload = request.get_json(silent=True) or {}
    companies = payload.get("companies")
    if not isinstance(companies, list):
        raise ValueError("Select at least one Tally company.")
    companies = list(dict.fromkeys(str(name).strip() for name in companies if str(name).strip()))
    if not companies:
        raise ValueError("Select at least one Tally company.")
    if len(companies) > 100:
        raise ValueError("Too many companies selected.")

    try:
        from_date = dt.datetime.strptime(str(payload.get("from_date", "")), "%Y-%m-%d").date()
        to_date = dt.datetime.strptime(str(payload.get("to_date", "")), "%Y-%m-%d").date()
    except ValueError as exc:
        raise ValueError("Use valid From and To dates.") from exc
    if from_date > to_date:
        raise ValueError("From date must be on or before To date.")
    return companies, from_date, to_date


def _excel_response(report_type, companies, from_date, to_date):
    rows = []
    errors = []
    for company in companies:
        try:
            if report_type == "sales":
                company_rows = get_sales_vouchers(company, from_date, to_date)
                for row in company_rows:
                    row["company"] = company
                rows.extend(company_rows)
            elif report_type == "debtor":
                rows.extend(get_billwise_debtor_rows(company, from_date, to_date))
            else:
                rows.extend(get_cost_centre_breakup(company, from_date, to_date))
        except TallyError as exc:
            errors.append(f"{company}: {exc}")

    if not rows and errors:
        raise TallyError("\n".join(errors))

    file_descriptor, path = tempfile.mkstemp(suffix=".xlsx")
    os.close(file_descriptor)
    try:
        if report_type == "sales":
            build_combined_workbook(rows, from_date, to_date, path)
        elif report_type == "debtor":
            build_billwise_debtor_workbook(rows, from_date, to_date, path)
        else:
            build_cost_centre_breakup_workbook(rows, from_date, to_date, path)
        with open(path, "rb") as workbook:
            output = io.BytesIO(workbook.read())
    finally:
        if os.path.exists(path):
            os.remove(path)

    response = send_file(
        output,
        as_attachment=True,
        download_name=REPORTS[report_type]["filename"],
        mimetype=REPORTS[report_type]["mimetype"],
    )
    if errors:
        response.headers["X-Tally-Warnings"] = str(len(errors))
    return response


def _debug_response(companies, from_date, to_date):
    output = io.BytesIO()
    with zipfile.ZipFile(output, "w", zipfile.ZIP_DEFLATED) as archive:
        for index, company in enumerate(companies, start=1):
            safe_name = "".join(char if char.isalnum() or char in "-_" else "_" for char in company).strip("_")
            safe_name = safe_name or f"company_{index}"
            file_descriptor, report_path = tempfile.mkstemp(suffix=".xml")
            os.close(file_descriptor)
            master_path = report_path + ".masters.xml"
            try:
                dump_native_cost_centre_xml(company, from_date, to_date, report_path)
                get_cost_centre_names(company, debug_dump_path=master_path)
                archive.write(report_path, f"{safe_name}_cost_centre_breakup.xml")
                archive.write(master_path, f"{safe_name}_master_list.xml")
            finally:
                for path in (report_path, master_path):
                    if os.path.exists(path):
                        os.remove(path)
    output.seek(0)
    return send_file(
        output,
        as_attachment=True,
        download_name=REPORTS["debug-xml"]["filename"],
        mimetype=REPORTS["debug-xml"]["mimetype"],
    )


@tally_connect_bp.get("/")
def page():
    from_date, to_date = _financial_year_dates()
    return render_template(
        "tally_connect.html",
        active_page="tally_connect",
        default_from=from_date.isoformat(),
        default_to=to_date.isoformat(),
    )


@tally_connect_bp.get("/api/companies")
def companies():
    try:
        names = get_open_companies()
        return jsonify({"success": True, "companies": names})
    except TallyError as exc:
        return jsonify({"success": False, "message": str(exc)}), 503


@tally_connect_bp.post("/api/reports/<report_type>")
def download_report(report_type):
    if report_type not in REPORTS:
        return jsonify({"success": False, "message": "Unknown report type."}), 404
    try:
        selected, from_date, to_date = _request_values()
        if report_type == "debug-xml":
            return _debug_response(selected, from_date, to_date)
        return _excel_response(report_type, selected, from_date, to_date)
    except ValueError as exc:
        return jsonify({"success": False, "message": str(exc)}), 400
    except TallyError as exc:
        return jsonify({"success": False, "message": str(exc)}), 503
    except Exception as exc:
        return jsonify({"success": False, "message": f"Unable to generate report: {exc}"}), 500
