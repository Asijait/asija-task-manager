document.addEventListener('DOMContentLoaded', function() {
    console.log("Billing Report Application Initialized");

    const flashMessages = document.querySelectorAll('.flash-message');
    flashMessages.forEach(msg => {
        setTimeout(() => {
            msg.style.opacity = '0';
            setTimeout(() => msg.remove(), 500);
        }, 2000);
    });

    const table = document.getElementById('reportTable');
    if (!table) return;

    const isReceiptsPage = document.body.dataset.activePage === 'receipts';
    const isOverduePage = document.body.dataset.activePage === 'overdue_report';
    const isBulkDeletePage = document.body.dataset.activePage === 'bulk_delete_report';
    const receiptColumnIndexes = isReceiptsPage
        ? { select: 3, party: 4, amount: 5, dueDate: 6, overdue: 7, group: 8, hidden: [9, 10, 11, 12, 13], edit: 14 }
        : { select: 13, party: 3, amount: 4, dueDate: 5, overdue: 6, group: 7, hidden: [], edit: 14 };
    const receiptHiddenColumns = new Set(receiptColumnIndexes.hidden);

    if (isReceiptsPage) {
        moveColumn(table, 13, 3);
    }

    const tbody = table.querySelector('tbody');
    const rows_el = Array.from(tbody.querySelectorAll('tr'));
    const filterableColumns = isReceiptsPage
        ? [0, 1, 2, receiptColumnIndexes.party, receiptColumnIndexes.overdue, receiptColumnIndexes.group]
        : (isOverduePage ? [0, 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12] : [0, 1, 2, 3, 6, 7, 8, 9, 10, 11, 12]);
    const dateColumns = new Set(isReceiptsPage ? [1, receiptColumnIndexes.dueDate] : (isOverduePage ? [0, 5] : [1, 5]));
    const numberColumns = new Set(isReceiptsPage ? [receiptColumnIndexes.overdue] : [6]);
    const activeFilters = {};
    const activeNumberFilters = {};
    const filterButtonsByColumn = {};
    let updateBulkDeleteReportState = () => {};
    const columnLabels = Array.from(table.tHead.rows[0].cells).map(th => th.textContent.trim());
    const visibleColumns = new Set(columnLabels.map((_, index) => index));
    const pageStorageKey = isReceiptsPage ? 'receipts' : (isOverduePage ? 'overdue' : 'report');
    const filterStorageKey = `billingReportActiveFiltersV3:${pageStorageKey}`;
    const numberFilterStorageKey = `billingReportNumberFiltersV3:${pageStorageKey}`;
    const noMatchFilterValue = '__NO_MATCH__';

    function moveColumn(tableElement, fromIndex, toIndex) {
        const colgroup = tableElement.querySelector('colgroup');
        const cols = Array.from(colgroup?.children || []);
        const movingCol = cols[fromIndex];
        const targetCol = cols[toIndex];
        if (movingCol && targetCol) colgroup.insertBefore(movingCol, targetCol);

        Array.from(tableElement.rows).forEach(row => {
            const movingCell = row.cells[fromIndex];
            const targetCell = row.cells[toIndex];
            if (movingCell && targetCell) row.insertBefore(movingCell, targetCell);
        });
    }

    function loadStoredFilters() {
        try {
            const storedFilters = JSON.parse(localStorage.getItem(filterStorageKey) || '{}');
            Object.entries(storedFilters).forEach(([cellIndex, values]) => {
                if (Array.isArray(values) && values.length > 0) {
                    activeFilters[cellIndex] = new Set(values);
                }
            });
        } catch (error) {
            localStorage.removeItem(filterStorageKey);
        }

        try {
            const storedNumberFilters = JSON.parse(localStorage.getItem(numberFilterStorageKey) || '{}');
            Object.entries(storedNumberFilters).forEach(([cellIndex, expression]) => {
                if (typeof expression === 'string' && expression.trim()) {
                    activeNumberFilters[cellIndex] = expression.trim();
                }
            });
        } catch (error) {
            localStorage.removeItem(numberFilterStorageKey);
        }
    }

    function saveStoredFilters() {
        const storedFilters = {};
        Object.entries(activeFilters).forEach(([cellIndex, values]) => {
            if (values && values.size > 0) {
                storedFilters[cellIndex] = Array.from(values);
            }
        });
        localStorage.setItem(filterStorageKey, JSON.stringify(storedFilters));

        const storedNumberFilters = {};
        Object.entries(activeNumberFilters).forEach(([cellIndex, expression]) => {
            if (expression && expression.trim()) {
                storedNumberFilters[cellIndex] = expression.trim();
            }
        });
        localStorage.setItem(numberFilterStorageKey, JSON.stringify(storedNumberFilters));
    }

    function clearAllHeaderFilters() {
        Object.keys(activeFilters).forEach(cellIndex => {
            delete activeFilters[cellIndex];
        });
        Object.keys(activeNumberFilters).forEach(cellIndex => {
            delete activeNumberFilters[cellIndex];
        });

        document.querySelectorAll('.filter-menu input').forEach(input => {
            input.checked = false;
            input.indeterminate = false;
        });

        filterableColumns.forEach(cellIndex => {
            const button = filterButtonsByColumn[cellIndex];
            if (button) {
                button.classList.remove('is-filtered');
                button.title = 'Filter';
            }
        });

        localStorage.removeItem(filterStorageKey);
        localStorage.removeItem(numberFilterStorageKey);
        document.querySelectorAll('.filter-menu.is-open').forEach(menu => {
            menu.classList.remove('is-open');
        });
        filterTable();
    }

    loadStoredFilters();

    function setColumnVisibility(cellIndex, isVisible) {
        const displayValue = isVisible ? "" : "none";
        const col = table.querySelector(`colgroup col:nth-child(${cellIndex + 1})`);
        if (col) col.style.display = displayValue;

        Array.from(table.rows).forEach(row => {
            if (row.cells[cellIndex]) row.cells[cellIndex].style.display = displayValue;
        });

        if (isVisible) {
            visibleColumns.add(cellIndex);
        } else {
            visibleColumns.delete(cellIndex);
        }
    }

    function buildColumnChooser() {
        const button = document.getElementById('columnChooserBtn');
        const menu = document.getElementById('columnChooserMenu');
        const list = document.getElementById('columnChooserList');
        const selectAll = document.getElementById('selectAllColumns');
        const clear = document.getElementById('clearColumns');

        if (!button || !menu || !list || !selectAll || !clear) return;

        const chooserColumnIndexes = columnLabels
            .map((_, index) => index)
            .filter(index => index < columnLabels.length - 2)
            .filter(index => !(isReceiptsPage && index === receiptColumnIndexes.select))
            .filter(index => !(isReceiptsPage && receiptHiddenColumns.has(index)));
        const chooserColumnCount = chooserColumnIndexes.length;

        function updateColumnChooserButton() {
            const selectedCount = list.querySelectorAll('input:checked').length;
            const label = selectedCount === chooserColumnCount
                ? 'Selected All'
                : `Selected ${selectedCount} Column${selectedCount === 1 ? '' : 's'}`;
            button.title = label;
            button.setAttribute('aria-label', label);
            button.dataset.tooltip = label;
            if (selectedCount === chooserColumnCount) {
                return;
            } else {
                return;
            }
        }

        columnLabels.forEach((label, cellIndex) => {
            if (cellIndex >= columnLabels.length - 2) return;
            if (isReceiptsPage && cellIndex === receiptColumnIndexes.select) return;
            if (isReceiptsPage && receiptHiddenColumns.has(cellIndex)) return;

            const option = document.createElement('label');
            option.className = 'column-chooser-option';

            const checkbox = document.createElement('input');
            checkbox.type = 'checkbox';
            checkbox.checked = true;
            checkbox.value = String(cellIndex);

            const text = document.createElement('span');
            text.textContent = label;

            option.appendChild(checkbox);
            option.appendChild(text);
            list.appendChild(option);

            checkbox.addEventListener('change', () => {
                setColumnVisibility(cellIndex, checkbox.checked);
                updateColumnChooserButton();
            });
        });

        selectAll.addEventListener('click', () => {
            list.querySelectorAll('input').forEach(input => {
                input.checked = true;
                setColumnVisibility(Number(input.value), true);
            });
            updateColumnChooserButton();
        });

        clear.addEventListener('click', () => {
            list.querySelectorAll('input').forEach(input => {
                input.checked = false;
                setColumnVisibility(Number(input.value), false);
            });
            updateColumnChooserButton();
        });

        button.addEventListener('click', event => {
            event.stopPropagation();
            document.querySelectorAll('.filter-menu.is-open').forEach(openMenu => {
                openMenu.classList.remove('is-open');
            });
            menu.classList.toggle('is-open');
            button.setAttribute('aria-expanded', String(menu.classList.contains('is-open')));
        });

        menu.addEventListener('click', event => event.stopPropagation());
        updateColumnChooserButton();
    }

    function updateSummary() {
        const summaryData = {};
        const grandTotal = { count: 0, total: 0 };
        rows_el.forEach(row => {
            if (row.style.display !== "none") {
                const firm = row.cells[0].textContent.trim();
                const amountStr = row.querySelector('.amount').textContent.replace(/[^0-9.-]/g, '');
                const amount = parseFloat(amountStr) || 0;

                if (!summaryData[firm]) summaryData[firm] = { count: 0, total: 0 };
                summaryData[firm].count++;
                summaryData[firm].total += amount;
                grandTotal.count++;
                grandTotal.total += amount;
            }
        });

        document.querySelectorAll('.summary-item').forEach(item => {
            const isGrandTotal = item.dataset.summaryType === 'grand-total';
            const firm = item.getAttribute('data-firm');
            const data = isGrandTotal ? grandTotal : (summaryData[firm] || { count: 0, total: 0 });
            const totalSpan = item.querySelector('.total');

            item.querySelector('.count').textContent = data.count;
            totalSpan.textContent = data.total.toLocaleString('en-IN', {
                minimumFractionDigits: 2,
                maximumFractionDigits: 2
            });

            totalSpan.classList.remove('amt-red', 'amt-orange');
            if (data.total >= 2000000) {
                totalSpan.classList.add('amt-red');
            } else if (data.total >= 1000000) {
                totalSpan.classList.add('amt-orange');
            }
        });
    }

    function filterTable() {
        rows_el.forEach(row => {
            row.style.display = rowMatchesFilters(row) ? "" : "none";
        });
        updateSummary();
        updateBulkDeleteReportState();
    }

    function buildCurrentReportExport() {
        const exportButton = document.querySelector('.excel-export-btn[data-current-export-url]');
        if (!exportButton || isReceiptsPage) return;

        exportButton.addEventListener('click', event => {
            event.preventDefault();

            const rowIds = rows_el
                .filter(row => row.style.display !== 'none')
                .map(row => row.dataset.rowId)
                .filter(Boolean);

            if (!rowIds.length) {
                window.alert('No visible rows to export.');
                return;
            }

            const exportableColumns = Array.from(visibleColumns)
                .filter(cellIndex => isOverduePage || cellIndex < columnLabels.length - 2)
                .sort((a, b) => a - b);

            const form = document.createElement('form');
            form.method = 'post';
            form.action = exportButton.dataset.currentExportUrl;
            form.style.display = 'none';

            const rowsInput = document.createElement('input');
            rowsInput.type = 'hidden';
            rowsInput.name = 'row_ids';
            rowsInput.value = JSON.stringify(rowIds);
            form.appendChild(rowsInput);

            const columnsInput = document.createElement('input');
            columnsInput.type = 'hidden';
            columnsInput.name = 'columns';
            columnsInput.value = JSON.stringify(exportableColumns);
            form.appendChild(columnsInput);

            document.body.appendChild(form);
            form.submit();
            form.remove();
        });
    }

    function rowMatchesFilters(row, excludedCellIndex = null, includeExcludedNumberFilter = false) {
        return filterableColumns.every(cellIndex => {
            const isExcludedColumn = cellIndex === excludedCellIndex;
            if (isExcludedColumn && !includeExcludedNumberFilter) return true;

            const selectedValues = activeFilters[cellIndex];
            const numberExpression = activeNumberFilters[cellIndex];

            const cellText = row.cells[cellIndex].textContent.trim();
            if (numberExpression && !numberExpressionMatches(cellText, numberExpression)) return false;
            if (isExcludedColumn) return true;
            if (!selectedValues || selectedValues.size === 0) return true;
            return selectedValues.has(cellText);
        });
    }

    function updateFilterButton(button, cellIndex) {
        const selectedValues = activeFilters[cellIndex];
        const numberExpression = activeNumberFilters[cellIndex];
        const hasFilter = (selectedValues && selectedValues.size > 0) || Boolean(numberExpression);
        button.classList.toggle('is-filtered', hasFilter);
        const selectedLabel = selectedValues?.has(noMatchFilterValue)
            ? '0 selected'
            : `${selectedValues?.size || 0} selected`;
        button.title = numberExpression || (hasFilter ? selectedLabel : 'Filter');
    }

    function parseNumber(value) {
        const number = parseFloat(String(value).replace(/[^0-9.-]/g, ''));
        return Number.isFinite(number) ? number : null;
    }

    function numberExpressionMatches(cellText, expression) {
        const cellNumber = parseNumber(cellText);
        if (cellNumber === null) return false;

        const term = String(expression).trim();
        const structured = term.match(/^(>=|<=|>|<|=|==|!=|between):(-?\d+(?:\.\d+)?)(?::(-?\d+(?:\.\d+)?))?$/);
        if (structured) {
            const operator = structured[1];
            const first = Number(structured[2]);
            const second = Number(structured[3]);
            if (operator === 'between' && Number.isFinite(second)) {
                return cellNumber >= Math.min(first, second) && cellNumber <= Math.max(first, second);
            }
            if (operator === '>') return cellNumber > first;
            if (operator === '>=') return cellNumber >= first;
            if (operator === '<') return cellNumber < first;
            if (operator === '<=') return cellNumber <= first;
            if (operator === '!=' ) return cellNumber !== first;
            return cellNumber === first;
        }

        const comparison = term.match(/^(>=|<=|>|<|=|==|!=)\s*(-?\d+(?:\.\d+)?)$/);
        if (comparison) {
            const operator = comparison[1];
            const target = Number(comparison[2]);
            if (operator === '>') return cellNumber > target;
            if (operator === '>=') return cellNumber >= target;
            if (operator === '<') return cellNumber < target;
            if (operator === '<=') return cellNumber <= target;
            if (operator === '!=' ) return cellNumber !== target;
            return cellNumber === target;
        }

        const between = term.match(/^(-?\d+(?:\.\d+)?)\s*(?:-|to)\s*(-?\d+(?:\.\d+)?)$/i);
        if (between) {
            const start = Number(between[1]);
            const end = Number(between[2]);
            return cellNumber >= Math.min(start, end) && cellNumber <= Math.max(start, end);
        }

        const exact = parseNumber(term);
        return exact !== null && cellNumber === exact;
    }

    function setVisibleOptions(menu, searchText) {
        const term = searchText.trim().toLowerCase();
        const isDateTree = Boolean(menu.querySelector('.date-tree-option'));
        menu.querySelectorAll('.filter-option, .filter-group-label').forEach(option => {
            const matches = option.textContent.toLowerCase().includes(term);
            option.style.display = !term || matches ? "" : "none";
        });
        if (isDateTree && term) {
            menu.querySelectorAll('.date-tree-option').forEach(option => {
                const isMatch = option.textContent.toLowerCase().includes(term);
                if (!isMatch) return;
                option.style.display = "";
                const parentMonth = option.dataset.parentMonth;
                const parentYear = option.dataset.parentYear;
                if (parentMonth) {
                    const monthRow = menu.querySelector(`.date-tree-option[data-month-row="${parentMonth}"]`);
                    if (monthRow) {
                        monthRow.hidden = false;
                        monthRow.style.removeProperty('display');
                    }
                }
                if (parentYear) {
                    const yearRow = menu.querySelector(`.date-tree-option[data-year-row="${parentYear}"]`);
                    if (yearRow) {
                        yearRow.hidden = false;
                        yearRow.style.removeProperty('display');
                    }
                }
                option.hidden = false;
            });
        }
    }

    function positionFilterMenu(button, menu) {
        const rect = button.getBoundingClientRect();
        const width = Math.min(300, window.innerWidth - 16);
        const left = Math.min(Math.max(8, rect.left), window.innerWidth - width - 8);
        const top = Math.min(rect.bottom + 6, window.innerHeight - 90);

        menu.style.width = `${width}px`;
        menu.style.left = `${left}px`;
        menu.style.top = `${top}px`;
    }

    function parseDisplayDate(value) {
        const match = value.match(/^(\d{2})-(\d{2})-(\d{2})$/);
        if (!match) return null;

        const day = Number(match[1]);
        const month = Number(match[2]);
        const year = 2000 + Number(match[3]);
        const date = new Date(year, month - 1, day);

        if (date.getFullYear() !== year || date.getMonth() !== month - 1 || date.getDate() !== day) {
            return null;
        }

        return { day, month, year, value, date };
    }

    function monthName(month) {
        return new Date(2000, month - 1, 1).toLocaleString('en-IN', { month: 'long' });
    }

    function selectedDateValues(options) {
        return new Set(
            Array.from(options.querySelectorAll('input[data-date-value]:checked')).map(input => input.value)
        );
    }

    function dateValueInputs(options) {
        return Array.from(options.querySelectorAll('input[data-date-value]'));
    }

    function setDateTreeChildren(options, parentSelector, isExpanded) {
        options.querySelectorAll(parentSelector).forEach(row => {
            row.hidden = !isExpanded;
            if (row.dataset.monthRow) {
                if (isExpanded) {
                    row.dataset.expanded = 'false';
                    const toggle = row.querySelector('.date-tree-toggle');
                    if (toggle) toggle.textContent = '+';
                    setDateTreeChildren(options, `.date-tree-option[data-parent-month="${row.dataset.monthRow}"]`, false);
                    return;
                }
                row.dataset.expanded = 'false';
                const toggle = row.querySelector('.date-tree-toggle');
                if (toggle) toggle.textContent = '+';
                setDateTreeChildren(options, `.date-tree-option[data-parent-month="${row.dataset.monthRow}"]`, false);
            }
            if (!isExpanded && row.dataset.yearRow) {
                row.dataset.expanded = 'false';
                const toggle = row.querySelector('.date-tree-toggle');
                if (toggle) toggle.textContent = '+';
                setDateTreeChildren(options, `.date-tree-option[data-parent-year="${row.dataset.yearRow}"]`, false);
            }
        });
    }

    function createDateTreeRow({ level, label, input, rowDataset = {}, toggle = null }) {
        const row = document.createElement('div');
        row.className = `filter-option date-tree-option date-tree-level-${level}`;
        Object.entries(rowDataset).forEach(([key, value]) => {
            row.dataset[key] = value;
        });

        const toggleButton = document.createElement('button');
        toggleButton.type = 'button';
        toggleButton.className = 'date-tree-toggle';
        if (toggle) {
            toggleButton.textContent = toggle.text;
            toggleButton.setAttribute('aria-label', toggle.label);
            toggleButton.addEventListener('click', event => {
                event.stopPropagation();
                toggle.onClick(row, toggleButton);
            });
        } else {
            toggleButton.textContent = '';
            toggleButton.disabled = true;
            toggleButton.setAttribute('aria-hidden', 'true');
        }

        const text = document.createElement('span');
        text.textContent = label;

        row.appendChild(toggleButton);
        row.appendChild(input);
        row.appendChild(text);

        return row;
    }

    function syncParentDateChecks(options) {
        options.querySelectorAll('input[data-month-key]').forEach(monthInput => {
            const dates = Array.from(options.querySelectorAll(`input[data-parent-month="${monthInput.dataset.monthKey}"]`));
            monthInput.checked = dates.length > 0 && dates.every(input => input.checked);
            monthInput.indeterminate = dates.some(input => input.checked) && !monthInput.checked;
        });

        options.querySelectorAll('input[data-year-key]').forEach(yearInput => {
            const dates = Array.from(options.querySelectorAll(`input[data-parent-year="${yearInput.dataset.yearKey}"][data-date-value]`));
            yearInput.checked = dates.length > 0 && dates.every(input => input.checked);
            yearInput.indeterminate = dates.some(input => input.checked) && !yearInput.checked;
        });

        const selectAllInput = options.querySelector('input[data-select-all-dates]');
        if (selectAllInput) {
            const dates = dateValueInputs(options);
            selectAllInput.checked = dates.length > 0 && dates.every(input => input.checked);
            selectAllInput.indeterminate = dates.some(input => input.checked) && !selectAllInput.checked;
        }
    }

    function applyFilterFromOptions(options, button, cellIndex, isDateColumn, numberInput = null, operatorSelect = null, numberInputTo = null) {
        if (isDateColumn) {
            const selectedDates = selectedDateValues(options);
            const dateInputs = dateValueInputs(options);
            if (selectedDates.size === dateInputs.length) {
                delete activeFilters[cellIndex];
            } else if (selectedDates.size === 0) {
                activeFilters[cellIndex] = new Set([noMatchFilterValue]);
            } else {
                activeFilters[cellIndex] = selectedDates;
            }
        } else {
            activeFilters[cellIndex] = new Set(Array.from(options.querySelectorAll('input:checked')).map(input => input.value));
        }
        if (numberInput) {
            const expression = operatorSelect
                ? buildNumberConditionValue(operatorSelect, numberInput, numberInputTo)
                : numberInput.value.trim();
            if (expression) {
                activeNumberFilters[cellIndex] = expression;
            } else {
                delete activeNumberFilters[cellIndex];
            }
        }
        saveStoredFilters();
        updateFilterButton(button, cellIndex);
        filterTable();
    }

    function applyStoredFilterToMenu(options, button, cellIndex, isDateColumn) {
        const selectedValues = activeFilters[cellIndex];
        if (!selectedValues || selectedValues.size === 0) {
            if (isDateColumn) {
                options.querySelectorAll('input[data-select-all-dates], input[data-year-key], input[data-month-key], input[data-date-value]').forEach(input => {
                    input.checked = true;
                    input.indeterminate = false;
                });
                syncParentDateChecks(options);
            }
            return;
        }

        options.querySelectorAll('input').forEach(input => {
            input.checked = selectedValues.has(input.value);
        });

        if (isDateColumn) syncParentDateChecks(options);
        updateFilterButton(button, cellIndex);
    }

    function applyStoredNumberFilterToMenu(numberInput, cellIndex) {
        if (!numberInput) return;
        numberInput.value = activeNumberFilters[cellIndex] || '';
    }

    function buildNumberConditionValue(operatorSelect, numberInput, numberInputTo) {
        const operator = operatorSelect.value;
        const first = numberInput.value.trim();
        const second = numberInputTo.value.trim();
        if (!operator || !first) return '';
        if (operator === 'between') {
            return second ? `between:${first}:${second}` : '';
        }
        return `${operator}:${first}`;
    }

    function applyStoredNumberCondition(operatorSelect, numberInput, numberInputTo, cellIndex) {
        const expression = activeNumberFilters[cellIndex] || '';
        const structured = expression.match(/^(>=|<=|>|<|=|==|!=|between):(-?\d+(?:\.\d+)?)(?::(-?\d+(?:\.\d+)?))?$/);

        operatorSelect.value = '';
        numberInput.value = '';
        numberInputTo.value = '';

        if (structured) {
            operatorSelect.value = structured[1] === '==' ? '=' : structured[1];
            numberInput.value = structured[2] || '';
            numberInputTo.value = structured[3] || '';
        }

        numberInputTo.hidden = operatorSelect.value !== 'between';
    }

    function availableFilterValues(cellIndex) {
        return [...new Set(
            rows_el
                .filter(row => rowMatchesFilters(row, cellIndex, true))
                .map(row => row.cells[cellIndex].textContent.trim())
        )].sort((a, b) => a.localeCompare(b, undefined, { numeric: true, sensitivity: 'base' }));
    }

    function addRegularOptions(options, values, button, cellIndex) {
        values.forEach(value => {
            const option = document.createElement('label');
            option.className = 'filter-option';

            const checkbox = document.createElement('input');
            checkbox.type = 'checkbox';
            checkbox.value = value;

            const text = document.createElement('span');
            text.textContent = value || '(blank)';

            option.appendChild(checkbox);
            option.appendChild(text);
            options.appendChild(option);

        });
    }

    function addDateOptions(options, values, button, cellIndex) {
        const parsedDates = values
            .map(parseDisplayDate)
            .filter(Boolean)
            .sort((a, b) => a.date - b.date);

        const grouped = new Map();
        parsedDates.forEach(item => {
            if (!grouped.has(item.year)) grouped.set(item.year, new Map());
            const months = grouped.get(item.year);
            if (!months.has(item.month)) months.set(item.month, []);
            months.get(item.month).push(item);
        });

        const selectAllCheckbox = document.createElement('input');
        selectAllCheckbox.type = 'checkbox';
        selectAllCheckbox.dataset.selectAllDates = 'true';
        const selectAllRow = createDateTreeRow({
            level: 0,
            label: '(Select All)',
            input: selectAllCheckbox,
            rowDataset: { selectAllRow: 'true' },
        });
        selectAllRow.classList.add('date-tree-select-all');
        options.appendChild(selectAllRow);

        selectAllCheckbox.addEventListener('change', () => {
            options.querySelectorAll('input[data-year-key], input[data-month-key], input[data-date-value]').forEach(input => {
                input.checked = selectAllCheckbox.checked;
                input.indeterminate = false;
            });
            syncParentDateChecks(options);
        });

        grouped.forEach((months, year) => {
            const yearCheckbox = document.createElement('input');
            yearCheckbox.type = 'checkbox';
            yearCheckbox.dataset.yearKey = String(year);
            const yearRow = createDateTreeRow({
                level: 0,
                label: String(year),
                input: yearCheckbox,
                rowDataset: { yearRow: String(year), expanded: 'false' },
                toggle: {
                    text: '+',
                    label: `Toggle ${year}`,
                    onClick: (row, toggleButton) => {
                        const expanded = row.dataset.expanded !== 'false';
                        row.dataset.expanded = expanded ? 'false' : 'true';
                        toggleButton.textContent = expanded ? '+' : '-';
                        if (expanded) {
                            setDateTreeChildren(options, `.date-tree-option[data-parent-year="${year}"]`, false);
                        } else {
                            setDateTreeChildren(options, `.date-tree-option[data-parent-year="${year}"][data-month-row]`, true);
                        }
                    }
                }
            });
            yearRow.classList.add('filter-group-label');
            options.appendChild(yearRow);

            yearCheckbox.addEventListener('change', () => {
                options.querySelectorAll(`input[data-parent-year="${year}"]`).forEach(input => {
                    input.checked = yearCheckbox.checked;
                });
                syncParentDateChecks(options);
            });

            months.forEach((dates, month) => {
                const monthKey = `${year}-${String(month).padStart(2, '0')}`;
                const monthCheckbox = document.createElement('input');
                monthCheckbox.type = 'checkbox';
                monthCheckbox.dataset.monthKey = monthKey;
                monthCheckbox.dataset.parentYear = String(year);
                const monthRow = createDateTreeRow({
                    level: 1,
                    label: monthName(month),
                    input: monthCheckbox,
                    rowDataset: { monthRow: monthKey, parentYear: String(year), expanded: 'false' },
                    toggle: {
                        text: '+',
                        label: `Toggle ${monthName(month)} ${year}`,
                        onClick: (row, toggleButton) => {
                            const expanded = row.dataset.expanded !== 'false';
                            row.dataset.expanded = expanded ? 'false' : 'true';
                            toggleButton.textContent = expanded ? '+' : '-';
                            setDateTreeChildren(options, `.date-tree-option[data-parent-month="${monthKey}"]`, !expanded);
                        }
                    }
                });
                monthRow.classList.add('month-option');
                monthRow.hidden = true;
                options.appendChild(monthRow);

                monthCheckbox.addEventListener('change', () => {
                    options.querySelectorAll(`input[data-parent-month="${monthKey}"]`).forEach(input => {
                        input.checked = monthCheckbox.checked;
                    });
                    syncParentDateChecks(options);
                });

                dates.forEach(item => {
                    const dateCheckbox = document.createElement('input');
                    dateCheckbox.type = 'checkbox';
                    dateCheckbox.value = item.value;
                    dateCheckbox.dataset.dateValue = item.value;
                    dateCheckbox.dataset.parentMonth = monthKey;
                    dateCheckbox.dataset.parentYear = String(year);
                    const dateRow = createDateTreeRow({
                        level: 2,
                        label: item.value,
                        input: dateCheckbox,
                        rowDataset: { parentMonth: monthKey, parentYear: String(year) },
                    });
                    dateRow.classList.add('date-option');
                    dateRow.hidden = true;
                    options.appendChild(dateRow);

                    dateCheckbox.addEventListener('change', () => {
                        syncParentDateChecks(options);
                    });
                });
            });
        });

        const unmatched = values.filter(value => !parseDisplayDate(value));
        unmatched.forEach(value => {
            const option = document.createElement('label');
            option.className = 'filter-option';

            const checkbox = document.createElement('input');
            checkbox.type = 'checkbox';
            checkbox.value = value;
            checkbox.dataset.dateValue = value;

            const text = document.createElement('span');
            text.textContent = value || '(blank)';

            option.appendChild(checkbox);
            option.appendChild(text);
            options.appendChild(option);

            checkbox.addEventListener('change', () => {
                syncParentDateChecks(options);
            });
        });
    }

    function buildColumnFilter(th, cellIndex) {
        const label = th.textContent.trim();
        const isDateColumn = dateColumns.has(cellIndex);
        const isNumberColumn = numberColumns.has(cellIndex);
        th.textContent = "";

        const wrapper = document.createElement('div');
        wrapper.className = 'th-filter';

        const labelSpan = document.createElement('span');
        labelSpan.className = 'th-label';
        labelSpan.textContent = label;

        const button = document.createElement('button');
        button.type = 'button';
        button.className = 'filter-toggle';
        button.textContent = 'v';
        button.title = 'Filter';
        filterButtonsByColumn[cellIndex] = button;

        const menu = document.createElement('div');
        menu.className = 'filter-menu';

        const search = document.createElement('input');
        search.type = 'text';
        search.className = 'filter-search';
        search.placeholder = isDateColumn ? 'Search date/month/year' : 'Search';

        const numberCondition = document.createElement('div');
        numberCondition.className = 'filter-number-condition';

        const operatorSelect = document.createElement('select');
        operatorSelect.innerHTML = `
            <option value="">Number Filter</option>
            <option value=">">Greater Than (&gt;)</option>
            <option value=">=">Greater Than or Equal (&gt;=)</option>
            <option value="<">Less Than (&lt;)</option>
            <option value="<=">Less Than or Equal (&lt;=)</option>
            <option value="=">Equal (=)</option>
            <option value="!=">Not Equal (!=)</option>
            <option value="between">Between</option>
        `;

        const numberInput = document.createElement('input');
        numberInput.type = 'number';
        numberInput.placeholder = 'Number';

        const numberInputTo = document.createElement('input');
        numberInputTo.type = 'number';
        numberInputTo.placeholder = 'To';
        numberInputTo.hidden = true;

        numberCondition.appendChild(operatorSelect);
        numberCondition.appendChild(numberInput);
        numberCondition.appendChild(numberInputTo);

        const actions = document.createElement('div');
        actions.className = 'filter-actions';

        const selectAll = document.createElement('button');
        selectAll.type = 'button';
        selectAll.textContent = 'Select All';
        selectAll.hidden = isDateColumn;

        const clear = document.createElement('button');
        clear.type = 'button';
        clear.textContent = isDateColumn ? 'Cancel' : 'Clear';

        const ok = document.createElement('button');
        ok.type = 'button';
        ok.textContent = 'OK';

        const options = document.createElement('div');
        options.className = 'filter-options';

        function rebuildFilterOptions() {
            options.innerHTML = '';
            const values = availableFilterValues(cellIndex);

            if (isDateColumn) {
                addDateOptions(options, values, button, cellIndex);
            } else {
                addRegularOptions(options, values, button, cellIndex);
            }

            applyStoredFilterToMenu(options, button, cellIndex, isDateColumn);
            if (isNumberColumn) {
                applyStoredNumberCondition(operatorSelect, numberInput, numberInputTo, cellIndex);
            }
        }

        rebuildFilterOptions();

        selectAll.addEventListener('click', () => {
            if (isDateColumn) {
                options.querySelectorAll('input').forEach(input => {
                    input.checked = true;
                    input.indeterminate = false;
                });
                syncParentDateChecks(options);
                return;
            }
            options.querySelectorAll('.filter-option').forEach(option => {
                if (option.style.display !== 'none') {
                    option.querySelector('input').checked = true;
                }
            });
            if (isDateColumn) syncParentDateChecks(options);
        });

        clear.addEventListener('click', () => {
            if (isDateColumn) {
                menu.classList.remove('is-open');
                return;
            }
            options.querySelectorAll('input').forEach(input => {
                input.checked = false;
                input.indeterminate = false;
            });
            activeFilters[cellIndex] = new Set();
            if (isNumberColumn) {
                operatorSelect.value = '';
                numberInput.value = '';
                numberInputTo.value = '';
                numberInputTo.hidden = true;
                delete activeNumberFilters[cellIndex];
            }
            if (isDateColumn) syncParentDateChecks(options);
        });

        ok.addEventListener('click', () => {
            applyFilterFromOptions(
                options,
                button,
                cellIndex,
                isDateColumn,
                isNumberColumn ? numberInput : null,
                isNumberColumn ? operatorSelect : null,
                isNumberColumn ? numberInputTo : null
            );
            menu.classList.remove('is-open');
        });

        search.addEventListener('input', () => setVisibleOptions(menu, search.value));
        operatorSelect.addEventListener('change', () => {
            numberInputTo.hidden = operatorSelect.value !== 'between';
        });
        [numberInput, numberInputTo].forEach(input => input.addEventListener('keydown', event => {
            if (event.key === 'Enter') {
                event.preventDefault();
                applyFilterFromOptions(options, button, cellIndex, isDateColumn, numberInput, operatorSelect, numberInputTo);
                menu.classList.remove('is-open');
            }
        }));

        button.addEventListener('click', event => {
            event.stopPropagation();
            document.querySelectorAll('.filter-menu.is-open').forEach(openMenu => {
                if (openMenu !== menu) openMenu.classList.remove('is-open');
            });
            menu.classList.toggle('is-open');
            if (menu.classList.contains('is-open')) {
                rebuildFilterOptions();
                search.value = '';
                positionFilterMenu(button, menu);
                search.focus();
            }
        });

        menu.addEventListener('click', event => event.stopPropagation());

        actions.appendChild(selectAll);
        actions.appendChild(clear);
        actions.appendChild(ok);
        menu.appendChild(search);
        if (isNumberColumn) menu.appendChild(numberCondition);
        if (isDateColumn) {
            menu.appendChild(options);
            menu.appendChild(actions);
        } else {
            menu.appendChild(actions);
            menu.appendChild(options);
        }
        wrapper.appendChild(labelSpan);
        wrapper.appendChild(button);
        wrapper.appendChild(menu);
        th.appendChild(wrapper);
    }

    function applyUrlFilters() {
        if (isReceiptsPage || isOverduePage || isBulkDeletePage) return;

        const params = new URLSearchParams(window.location.search);
        const firm = (params.get('firm') || '').trim();
        const shouldFilterOverdue = params.get('overdue') === '1';
        const shouldClearFilters = params.get('clear_filters') === '1' || firm || shouldFilterOverdue;
        if (!shouldClearFilters) return;

        Object.keys(activeFilters).forEach(cellIndex => {
            delete activeFilters[cellIndex];
        });
        Object.keys(activeNumberFilters).forEach(cellIndex => {
            delete activeNumberFilters[cellIndex];
        });
        localStorage.removeItem(filterStorageKey);
        localStorage.removeItem(numberFilterStorageKey);

        if (firm) {
            activeFilters[0] = new Set([firm]);
        }
        if (shouldFilterOverdue) {
            activeNumberFilters[6] = '>30';
        }

        saveStoredFilters();
        Object.entries(filterButtonsByColumn).forEach(([cellIndex, button]) => {
            updateFilterButton(button, Number(cellIndex));
        });
    }

    filterableColumns.forEach(cellIndex => {
        const th = table.tHead.rows[0].cells[cellIndex];
        if (th) buildColumnFilter(th, cellIndex);
    });
    applyUrlFilters();
    filterTable();

    buildColumnChooser();
    buildCurrentReportExport();
    buildRowEditor();
    buildBulkDeleteReport();
    buildPartPaymentTooltip();
    if (isReceiptsPage) {
        receiptHiddenColumns.forEach(cellIndex => setColumnVisibility(cellIndex, false));
        buildReceiptPosting();
        buildReceiptColumnResizing();
    }

    document.getElementById('clearTableFiltersBtn')?.addEventListener('click', event => {
        event.stopPropagation();
        clearAllHeaderFilters();
    });

    document.addEventListener('click', () => {
        document.querySelectorAll('.filter-menu.is-open').forEach(menu => {
            menu.classList.remove('is-open');
        });
        const columnMenu = document.getElementById('columnChooserMenu');
        const columnButton = document.getElementById('columnChooserBtn');
        if (columnMenu) columnMenu.classList.remove('is-open');
        if (columnButton) columnButton.setAttribute('aria-expanded', 'false');
    });

    window.addEventListener('resize', () => {
        document.querySelectorAll('.filter-menu.is-open').forEach(menu => {
            menu.classList.remove('is-open');
        });
    });

    document.querySelector('.table-scroll')?.addEventListener('scroll', () => {
        document.querySelectorAll('.filter-menu.is-open').forEach(menu => {
            menu.classList.remove('is-open');
        });
    });

    function buildRowEditor() {
        const modal = document.getElementById('editModal');
        const title = document.getElementById('editModalTitle');
        const closeButton = document.getElementById('editModalClose');
        const cancelButton = document.getElementById('editCancelBtn');
        const form = document.getElementById('editRowForm');
        const addRecordButton = document.getElementById('addReportRecordBtn');
        const deleteRecordButton = document.getElementById('deleteReportRecordBtn');
        const partyNameInput = document.getElementById('editPartyName');
        const groupSelect = document.getElementById('editGroup');
        const crpInput = document.getElementById('editCrp');
        const addToMasterInput = document.getElementById('editAddToMaster');
        const checkboxes = Array.from(document.querySelectorAll('.row-select'));
        const editButtons = Array.from(document.querySelectorAll('.row-edit-btn'));
        const groupCrpData = document.getElementById('reportGroupCrpData');
        const masterClientData = document.getElementById('reportMasterClientData');
        const masterClientGroupData = document.getElementById('reportMasterClientGroupData');
        let groupCrpMap = {};
        let masterClientNames = new Set();
        let clientGroupMap = {};

        if (!modal) return;

        try {
            groupCrpMap = groupCrpData ? JSON.parse(groupCrpData.textContent || '{}') : {};
        } catch (error) {
            groupCrpMap = {};
        }

        try {
            const names = masterClientData ? JSON.parse(masterClientData.textContent || '[]') : [];
            masterClientNames = new Set(names.map(name => String(name || '').trim().toLowerCase()).filter(Boolean));
        } catch (error) {
            masterClientNames = new Set();
        }

        try {
            const clients = masterClientGroupData ? JSON.parse(masterClientGroupData.textContent || '[]') : [];
            clients.forEach(client => {
                const name = String(client.client_name || '').trim().toLowerCase();
                if (name) clientGroupMap[name] = client.client_group || '';
            });
        } catch (error) {
            clientGroupMap = {};
        }

        function setSelected(checkbox) {
            checkboxes.forEach(item => {
                if (item !== checkbox) item.checked = false;
            });
        }

        function setValue(id, value) {
            const input = document.getElementById(id);
            if (input) input.value = value || '';
        }

        function setSelectValue(id, value) {
            const select = document.getElementById(id);
            if (!select) return;

            const selectedValue = value || '';
            select.value = selectedValue;
        }

        function updateCrpFromGroup() {
            if (!groupSelect || !crpInput) return;
            crpInput.value = groupCrpMap[groupSelect.value] || '';
        }

        function updateGroupFromParty() {
            if (!partyNameInput || !groupSelect) return;
            const partyKey = partyNameInput.value.trim().toLowerCase();
            const mappedGroup = clientGroupMap[partyKey];
            if (mappedGroup) {
                setSelectValue('editGroup', mappedGroup);
                updateCrpFromGroup();
            }
        }

        function openEditor(row) {
            if (title) title.textContent = 'Edit Report Row';
            if (form?.dataset.updateUrl) form.action = form.dataset.updateUrl;
            if (deleteRecordButton) deleteRecordButton.hidden = false;
            setSelectValue('editFirmName', row.dataset.firmName);
            setValue('editRowId', row.dataset.rowId);
            setValue('editRefNo', row.dataset.refNo);
            setValue('editBillDate', row.dataset.billDate);
            setValue('editPartyName', row.dataset.partyName);
            setSelectValue('editGroup', row.dataset.clientGroup);
            setValue('editAmount', row.dataset.amount);
            setValue('editFollowupPartner', row.dataset.followupPartner);
            setSelectValue('editFinalEp', row.dataset.finalEp);
            updateCrpFromGroup();
            if (crpInput && !crpInput.value) crpInput.value = row.dataset.crp || '';
            if (addToMasterInput) addToMasterInput.value = 'no';
            modal.classList.add('is-open');
            modal.setAttribute('aria-hidden', 'false');
        }

        function openAddEditor() {
            if (title) title.textContent = 'Add New Record';
            if (form?.dataset.addUrl) form.action = form.dataset.addUrl;
            if (deleteRecordButton) deleteRecordButton.hidden = true;
            if (form) form.reset();
            setValue('editRowId', '');
            setValue('editRefNo', '');
            setValue('editBillDate', '');
            setValue('editPartyName', '');
            setValue('editAmount', '');
            setValue('editFollowupPartner', '');
            setValue('editCrp', '');
            setSelectValue('editFirmName', '');
            setSelectValue('editGroup', '');
            setSelectValue('editFinalEp', '');
            if (addToMasterInput) addToMasterInput.value = 'no';
            modal.classList.add('is-open');
            modal.setAttribute('aria-hidden', 'false');
            document.getElementById('editFirmName')?.focus();
        }

        function closeEditor() {
            modal.classList.remove('is-open');
            modal.setAttribute('aria-hidden', 'true');
        }

        checkboxes.forEach(checkbox => {
            checkbox.addEventListener('change', () => {
                if (isReceiptsPage) return;
                if (checkbox.checked) setSelected(checkbox);
            });
        });

        editButtons.forEach(button => {
            button.addEventListener('click', () => {
                const row = button.closest('tr');
                const checkbox = row.querySelector('.row-select');
                if (checkbox && !checkbox.checked) {
                    checkbox.checked = true;
                    setSelected(checkbox);
                }
                openEditor(row);
            });
        });

        if (closeButton) closeButton.addEventListener('click', closeEditor);
        if (cancelButton) cancelButton.addEventListener('click', closeEditor);
        if (addRecordButton) addRecordButton.addEventListener('click', openAddEditor);
        if (groupSelect) groupSelect.addEventListener('change', updateCrpFromGroup);
        if (partyNameInput) {
            partyNameInput.addEventListener('change', updateGroupFromParty);
            partyNameInput.addEventListener('input', updateGroupFromParty);
        }
        if (form) {
            form.addEventListener('submit', event => {
                if (event.submitter && event.submitter.id === 'deleteReportRecordBtn') return;
                if (!partyNameInput || !addToMasterInput) return;

                const partyName = partyNameInput.value.trim();
                const masterKey = partyName.toLowerCase();
                addToMasterInput.value = 'no';

                if (partyName && !masterClientNames.has(masterKey)) {
                    const shouldAdd = window.confirm(`${partyName} is not in Client Master. Add it to master?`);
                    addToMasterInput.value = shouldAdd ? 'yes' : 'no';
                }
            });
        }
        modal.addEventListener('click', event => {
            if (event.target === modal) closeEditor();
        });
        document.addEventListener('keydown', event => {
            if (event.key === 'Escape') closeEditor();
        });
    }

    function buildBulkDeleteReport() {
        if (!isBulkDeletePage) return;

        const form = document.getElementById('controlBulkDeleteForm');
        const submitButton = document.getElementById('bulkDeleteSubmitBtn');
        const selectedText = document.getElementById('bulkDeleteSelectedText');
        const selectVisible = document.getElementById('bulkDeleteSelectVisible');
        const checkboxes = Array.from(document.querySelectorAll('.bulk-delete-row-check'));
        if (!form || !submitButton) return;

        function visibleCheckboxes() {
            return checkboxes.filter(checkbox => {
                const row = checkbox.closest('tr');
                return row && row.style.display !== 'none';
            });
        }

        function selectedCheckboxes() {
            return checkboxes.filter(checkbox => checkbox.checked);
        }

        function updateState() {
            const selected = selectedCheckboxes();
            const visible = visibleCheckboxes();
            const selectedVisible = visible.filter(checkbox => checkbox.checked);
            submitButton.disabled = selected.length === 0;
            submitButton.textContent = selected.length ? `Bulk Delete (${selected.length})` : 'Bulk Delete';
            if (selectedText) {
                selectedText.textContent = `${selected.length} record${selected.length === 1 ? '' : 's'} selected`;
            }
            if (selectVisible) {
                selectVisible.checked = visible.length > 0 && selectedVisible.length === visible.length;
                selectVisible.indeterminate = selectedVisible.length > 0 && selectedVisible.length < visible.length;
            }
        }

        updateBulkDeleteReportState = updateState;

        checkboxes.forEach(checkbox => {
            checkbox.addEventListener('change', updateState);
        });

        if (selectVisible) {
            selectVisible.addEventListener('change', () => {
                visibleCheckboxes().forEach(checkbox => {
                    checkbox.checked = selectVisible.checked;
                });
                updateState();
            });
        }

        form.addEventListener('submit', event => {
            const selected = selectedCheckboxes();
            if (!selected.length) {
                event.preventDefault();
                return;
            }
            if (!window.confirm(`Move ${selected.length} selected record(s) to Deleted Records? You can recall them later.`)) {
                event.preventDefault();
            }
        });

        updateState();
    }

    function buildPartPaymentTooltip() {
        const paymentRows = Array.from(document.querySelectorAll('.has-part-payment[data-receipt-note]'));
        if (!paymentRows.length) return;

        const tooltip = document.createElement('div');
        tooltip.className = 'part-payment-tooltip';
        tooltip.hidden = true;
        document.body.appendChild(tooltip);

        function positionTooltip(row) {
            const note = row.dataset.receiptNote || '';
            if (!note.trim()) return;
            tooltip.textContent = note;
            tooltip.hidden = false;

            const rect = row.getBoundingClientRect();
            const tooltipRect = tooltip.getBoundingClientRect();
            const margin = 8;
            let left = rect.left + margin;
            let top = rect.bottom + 6;

            if (left + tooltipRect.width > window.innerWidth - margin) {
                left = window.innerWidth - tooltipRect.width - margin;
            }
            if (top + tooltipRect.height > window.innerHeight - margin) {
                top = Math.max(margin, rect.top - tooltipRect.height - 6);
            }

            tooltip.style.left = `${Math.max(margin, left)}px`;
            tooltip.style.top = `${Math.max(margin, top)}px`;
        }

        function hideTooltip() {
            tooltip.hidden = true;
        }

        paymentRows.forEach(row => {
            row.addEventListener('mouseenter', () => positionTooltip(row));
            row.addEventListener('mousemove', () => positionTooltip(row));
            row.addEventListener('mouseleave', hideTooltip);
        });

        document.querySelector('.table-scroll')?.addEventListener('scroll', hideTooltip);
        window.addEventListener('resize', hideTooltip);
    }

    function buildReceiptPosting() {
        const postButton = document.getElementById('postReceiptBtn');
        const modal = document.getElementById('receiptModal');
        const receiptRows = document.getElementById('receiptRows');
        const receiptDate = document.getElementById('receiptDate');
        const receiptMode = document.getElementById('receiptMode');
        const receiptAmountHeader = document.getElementById('receiptAmountHeader');
        const closeButton = document.getElementById('receiptModalClose');
        const cancelButton = document.getElementById('receiptCancelBtn');
        const submitButton = document.getElementById('receiptSubmitBtn');
        const checkboxes = Array.from(document.querySelectorAll('.row-select'));

        if (!postButton || !modal || !receiptRows) return;

        function selectedRows() {
            return checkboxes
                .filter(checkbox => checkbox.checked)
                .map(checkbox => checkbox.closest('tr'))
                .filter(row => row && row.style.display !== 'none');
        }

        function updatePostButton() {
            postButton.hidden = selectedRows().length === 0;
        }

        function setDefaultReceiptDate() {
            if (!receiptDate || receiptDate.value) return;
            const today = new Date();
            const yyyy = today.getFullYear();
            const mm = String(today.getMonth() + 1).padStart(2, '0');
            const dd = String(today.getDate()).padStart(2, '0');
            receiptDate.value = `${yyyy}-${mm}-${dd}`;
        }

        function updateReceiptPostingLabels() {
            const mode = receiptMode?.value || 'Cash';
            const isAdjustment = mode === 'Bad Debt' || mode === 'Discount';
            if (receiptAmountHeader) {
                receiptAmountHeader.textContent = isAdjustment ? 'Adjustment Amount' : 'Actual Received Amt';
            }
            if (submitButton) {
                submitButton.textContent = isAdjustment ? `Post ${mode}` : 'Post Receipt';
            }
        }

        function addReceiptCell(row, text) {
            const cell = document.createElement('td');
            cell.textContent = text || '';
            row.appendChild(cell);
        }

        function openReceiptModal() {
            receiptRows.innerHTML = '';

            selectedRows().forEach(row => {
                const receiptRow = document.createElement('tr');
                addReceiptCell(receiptRow, row.dataset.refNo);
                addReceiptCell(receiptRow, row.dataset.partyName);
                addReceiptCell(receiptRow, row.cells[receiptColumnIndexes.amount]?.textContent.trim() || '');

                const amountCell = document.createElement('td');
                const input = document.createElement('input');
                input.type = 'number';
                input.step = '0.01';
                input.min = '0';
                input.value = row.dataset.amount || '';
                input.className = 'receipt-actual-input';
                input.dataset.rowId = row.dataset.rowId;
                amountCell.appendChild(input);
                receiptRow.appendChild(amountCell);
                receiptRows.appendChild(receiptRow);
            });

            setDefaultReceiptDate();
            modal.classList.add('is-open');
            modal.setAttribute('aria-hidden', 'false');
        }

        function closeReceiptModal() {
            modal.classList.remove('is-open');
            modal.setAttribute('aria-hidden', 'true');
        }

        checkboxes.forEach(checkbox => {
            checkbox.addEventListener('change', updatePostButton);
        });

        postButton.addEventListener('click', openReceiptModal);
        if (receiptMode) receiptMode.addEventListener('change', updateReceiptPostingLabels);
        if (closeButton) closeButton.addEventListener('click', closeReceiptModal);
        if (cancelButton) cancelButton.addEventListener('click', closeReceiptModal);
        async function submitReceipt() {
            const rows = Array.from(receiptRows.querySelectorAll('.receipt-actual-input')).map(input => ({
                row_id: input.dataset.rowId,
                received_amount: input.value
            }));

            if (!rows.length) return;
            if (!receiptDate?.value) {
                alert('Please select posting date.');
                return;
            }

            submitButton.disabled = true;
            try {
                const response = await fetch(modal.dataset.postUrl, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        receipt_mode: receiptMode?.value || '',
                        receipt_date: receiptDate.value,
                        rows
                    })
                });
                const result = await response.json();
                if (!response.ok || !result.success) {
                    alert(result.message || 'Unable to post receipt.');
                    return;
                }
                window.location.href = result.redirect_url || '/receipt-register';
            } catch (error) {
                alert('Unable to post receipt.');
            } finally {
                submitButton.disabled = false;
            }
        }

        if (submitButton) submitButton.addEventListener('click', submitReceipt);
        modal.addEventListener('click', event => {
            if (event.target === modal) closeReceiptModal();
        });
        document.addEventListener('keydown', event => {
            if (event.key === 'Escape') closeReceiptModal();
        });

        updatePostButton();
        updateReceiptPostingLabels();
    }

    function buildReceiptColumnResizing() {
        const storageKey = 'receiptReportColumnWidthsV1';
        const minimumWidth = 44;
        let storedWidths = {};

        try {
            storedWidths = JSON.parse(localStorage.getItem(storageKey) || '{}');
        } catch (error) {
            localStorage.removeItem(storageKey);
        }

        function tableCols() {
            return Array.from(table.querySelectorAll('colgroup col'));
        }

        function applyStoredWidths() {
            tableCols().forEach((col, index) => {
                const width = Number(storedWidths[index]);
                if (Number.isFinite(width) && width >= minimumWidth) {
                    col.style.width = `${width}px`;
                }
            });
        }

        function saveWidth(index, width) {
            storedWidths[index] = Math.max(minimumWidth, Math.round(width));
            localStorage.setItem(storageKey, JSON.stringify(storedWidths));
        }

        applyStoredWidths();

        Array.from(table.tHead.rows[0].cells).forEach((th, index) => {
            if (receiptHiddenColumns.has(index)) return;
            th.classList.add('resizable-column');

            const handle = document.createElement('span');
            handle.className = 'column-resize-handle';
            handle.setAttribute('aria-hidden', 'true');
            th.appendChild(handle);

            handle.addEventListener('mousedown', event => {
                event.preventDefault();
                event.stopPropagation();

                const col = tableCols()[index];
                const startX = event.clientX;
                const startWidth = col?.getBoundingClientRect().width || th.getBoundingClientRect().width;

                function onMouseMove(moveEvent) {
                    const nextWidth = Math.max(minimumWidth, startWidth + moveEvent.clientX - startX);
                    if (col) col.style.width = `${nextWidth}px`;
                }

                function onMouseUp() {
                    document.body.classList.remove('is-resizing-column');
                    document.removeEventListener('mousemove', onMouseMove);
                    document.removeEventListener('mouseup', onMouseUp);
                    const finalWidth = col?.getBoundingClientRect().width || th.getBoundingClientRect().width;
                    saveWidth(index, finalWidth);
                }

                document.body.classList.add('is-resizing-column');
                document.addEventListener('mousemove', onMouseMove);
                document.addEventListener('mouseup', onMouseUp);
            });
        });
    }
});
