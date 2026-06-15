document.addEventListener('DOMContentLoaded', function() {
    const table = document.getElementById('detailedReportTable');
    if (!table) return;

    const tbody = table.querySelector('tbody');
    const rows = Array.from(tbody.querySelectorAll('tr'));
    const headers = table.tHead.rows[0].cells;
    const activeFilters = {};
    const followupLinks = document.querySelectorAll('.followup-summary-link');
    const clickableSummaryRows = document.querySelectorAll('.clickable-summary-row');
    const clickableSummaryCells = document.querySelectorAll('.clickable-summary-cell');

    function escapeHtml(value) {
        return String(value || '').replace(/[&<>"']/g, char => ({
            '&': '&amp;',
            '<': '&lt;',
            '>': '&gt;',
            '"': '&quot;',
            "'": '&#39;'
        }[char]));
    }

    function normalizeFollowup(value) {
        const text = String(value || '').trim();
        return text || 'Unassigned';
    }

    function openFollowupDetail(partner) {
        const normalizedPartner = normalizeFollowup(partner);
        const matchingRows = rows.filter(row => normalizeFollowup(row.cells[7].textContent) === normalizedPartner);
        const totalText = matchingRows.length === 1 ? '1 record' : `${matchingRows.length} records`;
        const popup = window.open('', `followup_detail_${Date.now()}`, 'width=1200,height=720,scrollbars=yes,resizable=yes');

        if (!popup) {
            alert('Please allow popups to open the detailed report.');
            return;
        }

        const rowHtml = matchingRows.map(row => {
            const cells = Array.from(row.cells).map((cell, index) => {
                const className = index === 5 ? ` class="${cell.className}"` : '';
                return `<td${className}>${escapeHtml(cell.textContent.trim())}</td>`;
            }).join('');
            return `<tr>${cells}</tr>`;
        }).join('');

        popup.document.open();
        popup.document.write(`<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${escapeHtml(normalizedPartner)} - Detailed Report</title>
    <style>
        body { margin: 0; padding: 16px; background: #f4f7f9; color: #2c3e50; font-family: Arial, sans-serif; }
        h1 { margin: 0 0 4px; font-size: 20px; }
        .meta { margin: 0 0 14px; color: #607d8b; font-size: 13px; }
        .table-wrap { max-height: calc(100vh - 92px); overflow: auto; border: 1px solid #ddd; background: #fff; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 8px 10px; border: 1px solid #ddd; text-align: left; font-size: 13px; white-space: nowrap; }
        th { position: sticky; top: 0; z-index: 1; background: #34495e; color: #fff; }
        .amount-cell { text-align: right; font-weight: bold; color: #2c3e50; }
        .amt-red { color: #e74c3c !important; font-weight: bold; }
        .amt-orange { color: #f39c12 !important; font-weight: bold; }
    </style>
</head>
<body>
    <h1>${escapeHtml(normalizedPartner)}</h1>
    <p class="meta">Followup Partner detailed report - ${escapeHtml(totalText)}</p>
    <div class="table-wrap">
        <table>
            <thead>
                <tr>
                    <th>Date</th>
                    <th>Ref No</th>
                    <th>Party Name</th>
                    <th>Group</th>
                    <th>Category</th>
                    <th>Amount</th>
                    <th>EP</th>
                    <th>Followup</th>
                    <th>FY</th>
                </tr>
            </thead>
            <tbody>
                ${rowHtml || '<tr><td colspan="9">No records found.</td></tr>'}
            </tbody>
        </table>
    </div>
</body>
</html>`);
        popup.document.close();
        popup.focus();
    }

    function filterTable() {
        rows.forEach(row => {
            let isVisible = true;
            Object.entries(activeFilters).forEach(([cellIndex, selectedValues]) => {
                if (selectedValues.size === 0) return;
                const cellText = row.cells[cellIndex].textContent.trim();
                if (!selectedValues.has(cellText)) isVisible = false;
            });
            row.style.display = isVisible ? "" : "none";
        });
    }

    function updateFilterButton(button, cellIndex) {
        const hasFilter = activeFilters[cellIndex] && activeFilters[cellIndex].size > 0;
        button.classList.toggle('is-filtered', hasFilter);
        button.title = hasFilter ? `${activeFilters[cellIndex].size} selected` : 'Filter';
    }

    function positionFilterMenu(button, menu) {
        const rect = button.getBoundingClientRect();
        const width = 220;
        let left = rect.left;
        let top = rect.bottom + 5;

        if (left + width > window.innerWidth) left = window.innerWidth - width - 10;
        if (top + 300 > window.innerHeight) top = rect.top - 310;
        if (left < 10) left = 10;
        if (top < 10) top = 10;

        menu.style.left = `${left}px`;
        menu.style.top = `${top}px`;
    }

    function buildFilter(th, cellIndex) {
        const labelText = th.textContent.trim();
        th.innerHTML = '';

        const wrapper = document.createElement('div');
        wrapper.className = 'th-filter';

        const label = document.createElement('span');
        label.textContent = labelText;

        const button = document.createElement('button');
        button.type = 'button';
        button.className = 'filter-toggle';
        button.textContent = '▼';

        const menu = document.createElement('div');
        menu.className = 'filter-menu';

        const search = document.createElement('input');
        search.type = 'text';
        search.className = 'filter-search';
        search.placeholder = 'Search...';

        const actions = document.createElement('div');
        actions.className = 'filter-actions';
        
        const selectAll = document.createElement('button');
        selectAll.type = 'button';
        selectAll.textContent = 'All';

        const clear = document.createElement('button');
        clear.type = 'button';
        clear.textContent = 'Clear';

        const ok = document.createElement('button');
        ok.type = 'button';
        ok.textContent = 'OK';
        ok.style.backgroundColor = '#3498db';
        ok.style.color = 'white';

        const optionsBox = document.createElement('div');
        optionsBox.className = 'filter-options';

        const values = [...new Set(rows.map(r => r.cells[cellIndex].textContent.trim()))]
            .sort((a, b) => a.localeCompare(b, undefined, { numeric: true, sensitivity: 'base' }));

        values.forEach(val => {
            const labelEl = document.createElement('label');
            labelEl.className = 'filter-option';
            const checkbox = document.createElement('input');
            checkbox.type = 'checkbox';
            checkbox.value = val;
            labelEl.appendChild(checkbox);
            labelEl.appendChild(document.createTextNode(val || '(blank)'));
            optionsBox.appendChild(labelEl);
        });

        selectAll.onclick = () => optionsBox.querySelectorAll('.filter-option').forEach(l => {
            if (l.style.display !== 'none') l.querySelector('input').checked = true;
        });
        clear.onclick = () => optionsBox.querySelectorAll('input').forEach(i => i.checked = false);
        ok.onclick = () => {
            activeFilters[cellIndex] = new Set(Array.from(optionsBox.querySelectorAll('input:checked')).map(i => i.value));
            updateFilterButton(button, cellIndex);
            filterTable();
            menu.classList.remove('is-open');
        };

        search.oninput = () => {
            const term = search.value.toLowerCase();
            optionsBox.querySelectorAll('.filter-option').forEach(l => {
                l.style.display = l.textContent.toLowerCase().includes(term) ? '' : 'none';
            });
        };

        button.onclick = (e) => {
            e.stopPropagation();
            const wasOpen = menu.classList.contains('is-open');
            document.querySelectorAll('.filter-menu.is-open').forEach(m => m.classList.remove('is-open'));
            if (!wasOpen) {
                menu.classList.add('is-open');
                positionFilterMenu(button, menu);
                search.focus();
            }
        };

        actions.append(selectAll, clear, ok);
        menu.append(search, actions, optionsBox);
        wrapper.append(label, button, menu);
        th.appendChild(wrapper);
    }

    Array.from(headers).forEach((th, idx) => buildFilter(th, idx));
    clickableSummaryRows.forEach(row => {
        row.addEventListener('click', event => {
            const url = row.dataset.detailUrl;
            if (!url) return;
            if (event.target.closest('a')) return;
            window.open(url, '_blank', 'noopener');
        });
    });
    clickableSummaryCells.forEach(cell => {
        cell.addEventListener('click', event => {
            event.stopPropagation();
            const url = cell.dataset.detailUrl;
            if (!url) return;
            window.open(url, '_blank', 'noopener');
        });
    });
    followupLinks.forEach(link => {
        link.addEventListener('click', () => openFollowupDetail(link.dataset.followupPartner));
    });
    document.onclick = () => document.querySelectorAll('.filter-menu.is-open').forEach(m => m.classList.remove('is-open'));
});
