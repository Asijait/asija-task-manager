document.addEventListener('DOMContentLoaded', function () {
    const form = document.getElementById('tallyReceiptForm');
    const dateInput = document.getElementById('tallyReceiptDate');
    const clearButton = document.getElementById('clearTallyDate');
    const statusBox = document.getElementById('tallyStatus');
    const metaBox = document.getElementById('tallyMeta');
    const rowsBody = document.getElementById('tallyReceiptRows');
    const postButton = document.getElementById('postTallyReceipts');
    const uploadForm = document.getElementById('tallyReceiptUploadForm');
    const chooseFileButton = document.getElementById('chooseTallyReceiptFile');
    const receiptFileInput = document.getElementById('tallyReceiptFileInput');
    const receiptFileName = document.getElementById('tallyReceiptFileName');
    const previewUrl = document.body.dataset.previewUrl;
    const postUrl = document.body.dataset.postUrl;
    const autoPreview = document.body.dataset.autoPreview === '1';
    let latestRows = [];
    const statusOrder = {
        Ready: 1,
        'Already Posted': 2,
        'Duplicate Preview': 3,
        'Missing Ref': 4,
        'Multiple Match': 5,
        'Excess Amount': 6,
        'Invalid Amount': 7,
        'Not Matched': 8
    };

    function setStatus(message, isError = false) {
        statusBox.textContent = message;
        statusBox.classList.toggle('is-error', isError);
    }

    function formatAmount(value) {
        const amount = Number(value || 0);
        return amount.toLocaleString('en-IN', {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        });
    }

    function setText(id, value) {
        const element = document.getElementById(id);
        if (element) element.textContent = value;
    }

    function sortRowsByStatus(rows) {
        return [...rows].sort((first, second) => {
            const firstStatus = first.post_status || '';
            const secondStatus = second.post_status || '';
            const firstRank = statusOrder[firstStatus] || 99;
            const secondRank = statusOrder[secondStatus] || 99;
            if (firstRank !== secondRank) return firstRank - secondRank;
            if (firstStatus !== secondStatus) return firstStatus.localeCompare(secondStatus);
            return String(first.receipt_date || '').localeCompare(String(second.receipt_date || ''))
                || String(first.voucher_no || '').localeCompare(String(second.voucher_no || ''), undefined, { numeric: true })
                || String(first.party_name || '').localeCompare(String(second.party_name || ''));
        });
    }

    function matchedBillText(item) {
        if (!item.matched_ref_no) return '';

        const amount = Number(item.matched_bill_amount || 0);
        const amountText = amount ? ` | Rs ${formatAmount(amount)}` : '';
        const dateText = item.posted_receipt_dates ? ` | ${item.posted_receipt_dates}` : '';
        const countText = item.posted_receipt_count > 1 ? ` | ${item.posted_receipt_count} receipts` : '';
        return `${item.matched_ref_no} - ${item.matched_party_name || ''}${amountText}${dateText}${countText}`;
    }

    function renderRows(rows) {
        rowsBody.innerHTML = '';

        if (!rows.length) {
            const row = document.createElement('tr');
            row.className = 'empty-row';
            const cell = document.createElement('td');
            cell.colSpan = 10;
            cell.textContent = 'No Tally receipts found for this selection.';
            row.appendChild(cell);
            rowsBody.appendChild(row);
            return;
        }

        rows.forEach(item => {
            const row = document.createElement('tr');
            const isAlreadyPosted = item.post_status === 'Already Posted';
            row.className = item.is_postable ? 'ready-row' : (isAlreadyPosted ? 'already-posted-row' : 'blocked-row');
            const cells = [
                item.receipt_date_display,
                item.party_name,
                item.voucher_type,
                item.voucher_no,
                item.reference_no,
                formatAmount(item.post_amount || item.credit_amount || item.reference_amount),
                matchedBillText(item),
                item.post_status || '',
                item.bank_name,
                (item.raw_rows || []).join(', ')
            ];

            cells.forEach((value, index) => {
                const cell = document.createElement('td');
                cell.textContent = value || '';
                if (index === 5) cell.className = 'amount-cell';
                if (index === 7) cell.className = item.is_postable ? 'status-ready' : (isAlreadyPosted ? 'status-already-posted' : 'status-blocked');
                if (index === 7 && item.post_message) cell.title = item.post_message;
                row.appendChild(cell);
            });

            rowsBody.appendChild(row);
        });
    }

    async function loadPreview(successMessage = '') {
        const params = new URLSearchParams();
        if (dateInput.value) params.set('date', dateInput.value);

        setStatus('Reading fcRece.xlsx...');
        metaBox.hidden = true;
        rowsBody.innerHTML = '';
        latestRows = [];
        if (postButton) postButton.disabled = true;

        try {
            const response = await fetch(`${previewUrl}?${params.toString()}`);
            const result = await response.json();

            if (!response.ok || !result.success) {
                setStatus(result.message || 'Unable to preview Tally receipts.', true);
                renderRows([]);
                return;
            }

            setText('tallyFileName', `File: ${result.file_name}`);
            setText('tallySheetName', `Sheet: ${result.sheet_name}`);
            setText('tallyStartRow', `Data starts after Date header: row ${result.data_start_row || '-'}`);
            metaBox.hidden = false;

            latestRows = sortRowsByStatus(result.rows || []);
            renderRows(latestRows);
            const readyCount = latestRows.filter(row => row.is_postable).length;
            const readyTotal = latestRows
                .filter(row => row.is_postable)
                .reduce((sum, row) => sum + Number(row.post_amount || 0), 0);
            if (postButton) postButton.disabled = readyCount === 0;
            const previewMessage = `${latestRows.length} receipt row(s) loaded. ${readyCount} ready to post. Ready total: ${formatAmount(readyTotal)}.`;
            setStatus(successMessage ? `${successMessage} ${previewMessage}` : previewMessage);
        } catch (error) {
            setStatus('Unable to preview Tally receipts.', true);
            renderRows([]);
        }
    }

    async function postReceipts() {
        const readyCount = latestRows.filter(row => row.is_postable).length;
        if (!readyCount) {
            alert('No ready receipts to post.');
            return;
        }

        const confirmed = confirm(`Post ${readyCount} matched Tally receipt(s) to Receipt Register?`);
        if (!confirmed) return;

        postButton.disabled = true;
        setStatus('Posting matched Tally receipts...');

        try {
            const response = await fetch(postUrl, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ date: dateInput.value || '' })
            });
            const result = await response.json();

            if (!response.ok || !result.success) {
                setStatus(result.message || 'Unable to post Tally receipts.', true);
                postButton.disabled = false;
                return;
            }

            setStatus(result.message || 'Tally receipts posted.');
            await loadPreview(result.message || 'Tally receipts posted.');
        } catch (error) {
            setStatus('Unable to post Tally receipts.', true);
            postButton.disabled = false;
        }
    }

    if (form) {
        form.addEventListener('submit', function (event) {
            event.preventDefault();
            loadPreview();
        });
    }

    if (clearButton) {
        clearButton.addEventListener('click', function () {
            dateInput.value = '';
            loadPreview();
        });
    }

    if (postButton) {
        postButton.addEventListener('click', postReceipts);
    }

    if (chooseFileButton && receiptFileInput) {
        chooseFileButton.addEventListener('click', function () {
            receiptFileInput.value = '';
            receiptFileInput.click();
        });
    }

    if (uploadForm && receiptFileInput) {
        receiptFileInput.addEventListener('change', function () {
            if (!receiptFileInput.files.length) return;
            if (receiptFileName) receiptFileName.textContent = `Selected: ${receiptFileInput.files[0].name}`;
            uploadForm.submit();
        });
    }

    if (autoPreview) {
        loadPreview();
    }
});
