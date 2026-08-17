document.addEventListener("DOMContentLoaded", () => {
    const reportLabels = {
        sales: "Sales Register",
        debtor: "Debtor Report",
        "cost-centre": "Cost Centre",
        "debug-xml": "Debug XML"
    };
    const companyList = document.getElementById("companyList");
    const refreshButton = document.getElementById("refreshCompanies");
    const generateButton = document.getElementById("generateReport");
    const status = document.getElementById("status");
    const progress = document.getElementById("progress");
    const selectionCount = document.getElementById("selectionCount");
    let reportType = "sales";

    function selectedCompanies() {
        return Array.from(companyList.querySelectorAll("input:checked"), input => input.value);
    }

    function updateSelectionCount() {
        selectionCount.textContent = `${selectedCompanies().length} selected`;
    }

    function setBusy(isBusy, message = "") {
        refreshButton.disabled = isBusy;
        generateButton.disabled = isBusy;
        progress.hidden = !isBusy;
        if (message) {
            status.textContent = message;
            status.classList.remove("error");
        }
    }

    function showError(message) {
        status.textContent = message;
        status.classList.add("error");
    }

    async function responseError(response) {
        try {
            const payload = await response.json();
            return payload.message || "Request failed.";
        } catch (_error) {
            return "Request failed.";
        }
    }

    refreshButton.addEventListener("click", async () => {
        setBusy(true, "Connecting to Tally Prime...");
        try {
            const response = await fetch("api/companies");
            if (!response.ok) throw new Error(await responseError(response));
            const payload = await response.json();
            companyList.replaceChildren();
            if (!payload.companies.length) {
                companyList.innerHTML = '<div class="empty-state">Tally is connected, but no open companies were found.</div>';
            } else {
                payload.companies.forEach(name => {
                    const label = document.createElement("label");
                    label.className = "company-option";
                    const checkbox = document.createElement("input");
                    checkbox.type = "checkbox";
                    checkbox.value = name;
                    checkbox.checked = true;
                    checkbox.addEventListener("change", updateSelectionCount);
                    const text = document.createElement("span");
                    text.textContent = name;
                    label.append(checkbox, text);
                    companyList.appendChild(label);
                });
            }
            updateSelectionCount();
            status.textContent = `Found ${payload.companies.length} open companies.`;
        } catch (error) {
            showError(error.message);
        } finally {
            setBusy(false);
        }
    });

    document.getElementById("selectAll").addEventListener("click", () => {
        companyList.querySelectorAll("input").forEach(input => { input.checked = true; });
        updateSelectionCount();
    });

    document.getElementById("clearAll").addEventListener("click", () => {
        companyList.querySelectorAll("input").forEach(input => { input.checked = false; });
        updateSelectionCount();
    });

    document.querySelectorAll(".report-btn").forEach(button => {
        button.addEventListener("click", () => {
            document.querySelectorAll(".report-btn").forEach(item => item.classList.remove("active"));
            button.classList.add("active");
            reportType = button.dataset.report;
            generateButton.textContent = `Download ${reportLabels[reportType]}`;
        });
    });

    generateButton.addEventListener("click", async () => {
        const companies = selectedCompanies();
        if (!companies.length) {
            showError("Select at least one Tally company.");
            return;
        }
        const fromDate = document.getElementById("fromDate").value;
        const toDate = document.getElementById("toDate").value;
        if (!fromDate || !toDate || fromDate > toDate) {
            showError("Choose valid dates and keep From on or before To.");
            return;
        }

        setBusy(true, `Generating ${reportLabels[reportType]} for ${companies.length} companies...`);
        try {
            const response = await fetch(`api/reports/${reportType}`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ companies, from_date: fromDate, to_date: toDate })
            });
            if (!response.ok) throw new Error(await responseError(response));
            const blob = await response.blob();
            const disposition = response.headers.get("Content-Disposition") || "";
            const encodedName = disposition.match(/filename\*=UTF-8''([^;]+)/i);
            const plainName = disposition.match(/filename="?([^";]+)"?/i);
            const filename = encodedName ? decodeURIComponent(encodedName[1]) : (plainName ? plainName[1] : "Tally_Report");
            const link = document.createElement("a");
            link.href = URL.createObjectURL(blob);
            link.download = filename;
            document.body.appendChild(link);
            link.click();
            link.remove();
            URL.revokeObjectURL(link.href);
            status.textContent = `${reportLabels[reportType]} downloaded successfully.`;
        } catch (error) {
            showError(error.message);
        } finally {
            setBusy(false);
        }
    });
});
