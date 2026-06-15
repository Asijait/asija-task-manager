(function () {
    const form = document.getElementById('chequeBounceForm');
    if (!form) {
        return;
    }

    const selectAll = document.getElementById('receiptSelectAll');
    const rowChecks = Array.from(form.querySelectorAll('.receipt-row-check'));
    const submitButton = document.getElementById('chequeBounceSubmit');
    const dialog = document.getElementById('chequeBounceDialog');
    const dateInput = document.getElementById('bounceDateInput');
    const reasonInput = document.getElementById('bounceReasonInput');
    const dateValue = document.getElementById('bounceDateValue');
    const reasonValue = document.getElementById('bounceReasonValue');
    const confirmButton = document.getElementById('chequeBounceConfirm');
    const cancelButtons = [
        document.getElementById('chequeBounceCancel'),
        document.getElementById('chequeBounceCancelTop'),
    ].filter(Boolean);

    function selectedCount() {
        return rowChecks.filter((checkbox) => checkbox.checked).length;
    }

    function refreshState() {
        const count = selectedCount();
        if (submitButton) {
            submitButton.disabled = count === 0;
            submitButton.classList.toggle('is-ready', count > 0);
        }
        if (selectAll) {
            selectAll.checked = count > 0;
            selectAll.indeterminate = false;
        }
    }

    function todayValue() {
        const now = new Date();
        const month = String(now.getMonth() + 1).padStart(2, '0');
        const day = String(now.getDate()).padStart(2, '0');
        return `${now.getFullYear()}-${month}-${day}`;
    }

    function openDialog() {
        if (!dialog || !dateInput) {
            return;
        }
        dateInput.value = dateInput.value || todayValue();
        if (reasonInput) {
            reasonInput.value = '';
        }
        dialog.setAttribute('aria-hidden', 'false');
        dateInput.focus();
    }

    function closeDialog() {
        if (dialog) {
            dialog.setAttribute('aria-hidden', 'true');
        }
    }

    if (selectAll) {
        selectAll.addEventListener('change', () => {
            if (selectAll.checked && rowChecks[0]) {
                rowChecks.forEach((checkbox, index) => {
                    checkbox.checked = index === 0;
                });
            } else {
                rowChecks.forEach((checkbox) => {
                    checkbox.checked = false;
                });
            }
            refreshState();
        });
    }

    rowChecks.forEach((checkbox) => {
        checkbox.addEventListener('change', () => {
            if (checkbox.checked) {
                rowChecks.forEach((otherCheckbox) => {
                    if (otherCheckbox !== checkbox) {
                        otherCheckbox.checked = false;
                    }
                });
            }
            refreshState();
        });
    });

    if (submitButton) {
        submitButton.addEventListener('click', () => {
            if (!selectedCount()) {
                return;
            }
            openDialog();
        });
    }

    cancelButtons.forEach((button) => {
        button.addEventListener('click', closeDialog);
    });

    if (dialog) {
        dialog.addEventListener('click', (event) => {
            if (event.target === dialog) {
                closeDialog();
            }
        });
    }

    if (confirmButton) {
        confirmButton.addEventListener('click', () => {
            if (!selectedCount()) {
                alert('Please select one receipt.');
                closeDialog();
                return;
            }
            if (!dateInput || !dateInput.value) {
                alert('Please select cheque bounce date.');
                return;
            }
            if (dateValue) {
                dateValue.value = dateInput.value;
            }
            if (reasonValue && reasonInput) {
                reasonValue.value = reasonInput.value.trim();
            }
            form.submit();
        });
    }

    form.addEventListener('submit', (event) => {
        const count = selectedCount();
        if (count !== 1) {
            event.preventDefault();
            alert('Please select one receipt.');
            return;
        }
        if (dateInput && dateValue && !dateValue.value) {
            event.preventDefault();
            openDialog();
        }
    });

    refreshState();
})();
