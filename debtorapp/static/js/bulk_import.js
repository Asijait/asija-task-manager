(function () {
    const form = document.getElementById('bulkImportConfirmForm');
    if (!form) return;
    const rowSelects = Array.from(form.querySelectorAll('.row-firm-select'));
    const groupSelects = Array.from(document.querySelectorAll('.group-firm-select'));
    const submitButton = document.getElementById('confirmBulkImport');
    const status = document.getElementById('firmSelectionStatus');

    function updateStatus() {
        const remaining = rowSelects.filter(select => !select.value).length;
        submitButton.disabled = remaining > 0;
        status.textContent = remaining
            ? `${remaining} bill(s) ki firm select karni baaki hai.`
            : `All ${rowSelects.length} bills are ready to import.`;
    }

    groupSelects.forEach(function (groupSelect) {
        groupSelect.addEventListener('change', function () {
            rowSelects.forEach(function (rowSelect) {
                if (rowSelect.dataset.sourceFirm === groupSelect.dataset.sourceFirm) {
                    rowSelect.value = groupSelect.value;
                }
            });
            updateStatus();
        });
    });
    rowSelects.forEach(select => select.addEventListener('change', updateStatus));
    form.addEventListener('submit', function (event) {
        if (rowSelects.some(select => !select.value)) {
            event.preventDefault();
            updateStatus();
            return;
        }
        if (!window.confirm(`Import ${rowSelects.length} bill(s) with the selected firms?`)) {
            event.preventDefault();
            return;
        }
        submitButton.disabled = true;
        submitButton.textContent = 'Importing...';
    });
    updateStatus();
})();
