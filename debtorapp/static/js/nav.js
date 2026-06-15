document.addEventListener('DOMContentLoaded', function() {
    const button = document.getElementById('navMenuBtn');
    const sidebar = document.getElementById('appSidebar');
    const topNav = document.querySelector('.top-nav');

    function cleanCurrentUrlWithoutImportPrompt() {
        const url = new URL(window.location.href);
        url.searchParams.delete('followup_prompt');
        url.searchParams.delete('import_batch');
        return url.pathname + url.search + url.hash;
    }

    function submitImportFollowupChoice(batchId, choice) {
        if (!topNav || !batchId) return;
        const debtorRoot = (topNav.dataset.debtorRoot || '/').replace(/\/$/, '');
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = debtorRoot + '/import-followup-choice';
        form.style.display = 'none';

        [
            ['batch_id', batchId],
            ['choice', choice],
            ['return_to', cleanCurrentUrlWithoutImportPrompt()]
        ].forEach(function(field) {
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = field[0];
            input.value = field[1];
            form.appendChild(input);
        });

        document.body.appendChild(form);
        form.submit();
    }

    const params = new URLSearchParams(window.location.search);
    const importBatch = params.get('import_batch');
    if (params.get('followup_prompt') === '1' && importBatch) {
        const shouldRunRule = window.confirm('Do you want to run Followup Partner Rule?\n\nOK = Yes\nCancel = No');
        submitImportFollowupChoice(importBatch, shouldRunRule ? 'yes' : 'no');
        return;
    }

    if (!button || !sidebar) return;

    if (topNav) {
        topNav.classList.remove('is-hidden');
        document.body.classList.remove('nav-hidden');
        document.body.classList.add('nav-visible');
    }

    function setOpen(isOpen) {
        sidebar.classList.toggle('is-open', isOpen);
        button.classList.toggle('is-active', isOpen);
        button.setAttribute('aria-expanded', String(isOpen));
    }

    button.addEventListener('click', function(event) {
        event.stopPropagation();
        setOpen(!sidebar.classList.contains('is-open'));
    });

    sidebar.addEventListener('click', function(event) {
        event.stopPropagation();
    });

    document.addEventListener('click', function() {
        setOpen(false);
    });

    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            setOpen(false);
            closeWeeklyReportDialog();
        }
    });

    let activeImportForm = null;
    const importDialog = document.getElementById('importDialog');
    const importDialogInput = document.getElementById('importFirmDialogInput');
    const importDialogClose = document.getElementById('importDialogClose');
    const importChooseFile = document.getElementById('importChooseFile');
    const importUseFileFirm = document.getElementById('importUseFileFirm');
    const weeklyReportDialog = document.getElementById('weeklyReportDialog');
    const weeklyReportClose = document.getElementById('weeklyReportDialogClose');
    const weeklyReportCancel = document.getElementById('weeklyReportCancel');

    function closeImportDialog() {
        if (!importDialog) return;
        importDialog.classList.remove('is-open');
        importDialog.setAttribute('aria-hidden', 'true');
    }

    function openImportDialog(form) {
        activeImportForm = form;
        if (!importDialog || !importDialogInput) return;
        importDialogInput.value = '';
        importDialog.classList.add('is-open');
        importDialog.setAttribute('aria-hidden', 'false');
        importDialogInput.focus();
    }

    function chooseImportFile(useFileFirmName) {
        if (!activeImportForm) return;

        const firmInput = activeImportForm.querySelector('.import-firm-name');
        const fileInput = activeImportForm.querySelector('.import-file-input');
        if (!firmInput || !fileInput) return;

        firmInput.value = useFileFirmName ? '' : (importDialogInput?.value || '').trim();
        closeImportDialog();
        fileInput.value = '';
        fileInput.click();
    }

    document.querySelectorAll('.import-data-form').forEach(function(form) {
        const importButton = form.querySelector('.import-data-btn');
        const fileInput = form.querySelector('.import-file-input');

        if (!importButton || !fileInput) return;

        importButton.addEventListener('click', function(event) {
            event.stopPropagation();
            openImportDialog(form);
        });

        fileInput.addEventListener('change', function() {
            if (fileInput.files.length > 0) {
                form.submit();
            }
        });
    });

    if (importDialog) {
        importDialog.addEventListener('click', function(event) {
            if (event.target === importDialog) closeImportDialog();
        });
    }
    if (importDialogClose) importDialogClose.addEventListener('click', closeImportDialog);
    if (importUseFileFirm) importUseFileFirm.addEventListener('click', function() {
        chooseImportFile(true);
    });
    if (importChooseFile) importChooseFile.addEventListener('click', function() {
        chooseImportFile(false);
    });
    if (importDialogInput) {
        importDialogInput.addEventListener('keydown', function(event) {
            if (event.key === 'Enter') {
                event.preventDefault();
                chooseImportFile(false);
            }
        });
    }

    function closeWeeklyReportDialog() {
        if (!weeklyReportDialog) return;
        weeklyReportDialog.classList.remove('is-open');
        weeklyReportDialog.setAttribute('aria-hidden', 'true');
    }

    function openWeeklyReportDialog() {
        if (!weeklyReportDialog) return;
        weeklyReportDialog.classList.add('is-open');
        weeklyReportDialog.setAttribute('aria-hidden', 'false');
        weeklyReportDialog.querySelector('input[name="start_date"]')?.focus();
    }

    if (weeklyReportDialog) {
        const weeklyStartInput = weeklyReportDialog.querySelector('input[name="start_date"]');
        const weeklyTotalFromInput = weeklyReportDialog.querySelector('input[name="cumulative_start_date"]');
        weeklyStartInput?.addEventListener('change', function() {
            if (weeklyTotalFromInput && !weeklyTotalFromInput.value) {
                weeklyTotalFromInput.value = weeklyStartInput.value;
            }
        });
    }

    document.querySelectorAll('.weekly-report-form').forEach(function(form) {
        const startInput = form.querySelector('input[name="start_date"]');
        const totalFromInput = form.querySelector('input[name="cumulative_start_date"]');
        startInput?.addEventListener('change', function() {
            if (totalFromInput && !totalFromInput.value) {
                totalFromInput.value = startInput.value;
            }
        });
    });

    document.querySelectorAll('.weekly-report-btn').forEach(function(reportButton) {
        reportButton.addEventListener('click', function(event) {
            event.preventDefault();
            event.stopPropagation();
            openWeeklyReportDialog();
        });
    });

    if (weeklyReportDialog) {
        weeklyReportDialog.addEventListener('click', function(event) {
            if (event.target === weeklyReportDialog) closeWeeklyReportDialog();
        });
    }
    if (weeklyReportClose) weeklyReportClose.addEventListener('click', closeWeeklyReportDialog);
    if (weeklyReportCancel) weeklyReportCancel.addEventListener('click', closeWeeklyReportDialog);

    const topNavLinks = document.querySelector('.top-nav-links');
    function hasDropdownButton(label) {
        return Array.from(topNavLinks.querySelectorAll(':scope > .nav-dropdown > .nav-dropdown-btn'))
            .some(button => button.textContent.trim() === label);
    }

    if (topNavLinks && !hasDropdownButton('Masters')) {
        const masterLinks = [
            topNavLinks.querySelector(':scope > a[href$="/client-master"]'),
            topNavLinks.querySelector(':scope > a[href$="/firm-master"]'),
            topNavLinks.querySelector(':scope > a[href$="/executive-partner-master"]')
        ].filter(Boolean);

        if (masterLinks.length === 3) {
            const dropdown = document.createElement('div');
            dropdown.className = 'nav-dropdown';

            const button = document.createElement('button');
            button.type = 'button';
            button.className = 'nav-dropdown-btn';
            button.setAttribute('aria-expanded', 'false');
            button.textContent = 'Masters';

            const menu = document.createElement('div');
            menu.className = 'nav-dropdown-menu';

            if (masterLinks.some(link => link.classList.contains('active'))) {
                button.classList.add('active');
            }

            dropdown.appendChild(button);
            dropdown.appendChild(menu);
            topNavLinks.insertBefore(dropdown, masterLinks[0]);
            masterLinks.forEach(link => menu.appendChild(link));
        }
    }

    if (topNavLinks && !hasDropdownButton('Receipts')) {
        const receiptLinks = [
            topNavLinks.querySelector(':scope > a[href$="/receipts"]'),
            topNavLinks.querySelector(':scope > a[href$="/receipt-register"]')
        ].filter(Boolean);

        if (receiptLinks.length === 2) {
            const dropdown = document.createElement('div');
            dropdown.className = 'nav-dropdown';

            const button = document.createElement('button');
            button.type = 'button';
            button.className = 'nav-dropdown-btn';
            button.setAttribute('aria-expanded', 'false');
            button.textContent = 'Receipts';

            const menu = document.createElement('div');
            menu.className = 'nav-dropdown-menu';

            if (receiptLinks.some(link => link.classList.contains('active'))) {
                button.classList.add('active');
            }

            dropdown.appendChild(button);
            dropdown.appendChild(menu);
            topNavLinks.insertBefore(dropdown, receiptLinks[0]);
            receiptLinks.forEach(link => menu.appendChild(link));
        }
    }

    if (topNavLinks && !hasDropdownButton('Import / Export')) {
        const exportLink = topNavLinks.querySelector(':scope > a[href$="/download/report-excel"]');
        const importForm = topNavLinks.querySelector(':scope > .nav-import-form');

        if (exportLink || importForm) {
            const dropdown = document.createElement('div');
            dropdown.className = 'nav-dropdown';

            const button = document.createElement('button');
            button.type = 'button';
            button.className = 'nav-dropdown-btn';
            button.setAttribute('aria-expanded', 'false');
            button.textContent = 'Import / Export';

            const menu = document.createElement('div');
            menu.className = 'nav-dropdown-menu';

            dropdown.appendChild(button);
            dropdown.appendChild(menu);
            topNavLinks.appendChild(dropdown);
            if (importForm) menu.appendChild(importForm);
            if (exportLink) menu.appendChild(exportLink);
        }
    }

    document.querySelectorAll('.nav-dropdown').forEach(function(dropdown) {
        const dropdownButton = dropdown.querySelector('.nav-dropdown-btn');
        if (!dropdownButton) return;

        dropdownButton.addEventListener('click', function(event) {
            event.stopPropagation();
            const isOpen = dropdown.classList.toggle('is-open');
            dropdownButton.setAttribute('aria-expanded', String(isOpen));
        });

        dropdown.addEventListener('click', function(event) {
            event.stopPropagation();
        });

        document.addEventListener('click', function() {
            dropdown.classList.remove('is-open');
            dropdownButton.setAttribute('aria-expanded', 'false');
        });
    });
});
