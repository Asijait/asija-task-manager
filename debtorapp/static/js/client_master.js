document.addEventListener('DOMContentLoaded', function() {
    console.log("Client Master Module Initialized");
    
    const flashMessages = document.querySelectorAll('.flash-message');
    flashMessages.forEach(msg => {
        setTimeout(() => {
            msg.style.opacity = '0';
            setTimeout(() => msg.remove(), 500);
        }, 2000);
    });

    const showFormButton = document.getElementById('showClientFormBtn');
    const hideFormButton = document.getElementById('hideClientFormBtn');
    const formSection = document.getElementById('clientFormSection');

    if (showFormButton && formSection) {
        showFormButton.addEventListener('click', () => {
            formSection.hidden = false;
            const firstInput = formSection.querySelector('input');
            if (firstInput) firstInput.focus();
        });
    }

    if (hideFormButton && formSection) {
        hideFormButton.addEventListener('click', () => {
            formSection.hidden = true;
        });
    }

    const groupSelect = document.getElementById('clientGroupSelect');
    const groupInput = document.getElementById('clientGroupInput');
    const groupOptions = document.getElementById('clientGroupOptions');
    const crpInput = document.getElementById('clientCrpInput');
    const referredInput = document.getElementById('clientReferredInput');
    const groupCrpData = document.getElementById('groupCrpData');
    const groupMasterData = document.getElementById('groupMasterData');
    let groupCrpMap = {};
    let groupMasterMap = {};

    if (groupCrpData) {
        try {
            groupCrpMap = JSON.parse(groupCrpData.textContent || '{}');
        } catch (error) {
            groupCrpMap = {};
        }
    }

    if (groupMasterData) {
        try {
            groupMasterMap = JSON.parse(groupMasterData.textContent || '{}');
        } catch (error) {
            groupMasterMap = {};
        }
    }

    function primaryCrpForGroup(groupName) {
        const crpList = groupCrpMap[(groupName || '').trim()] || [];
        return crpList[0] || '';
    }

    function parentForGroup(groupName) {
        return groupMasterMap[(groupName || '').trim()] || null;
    }

    function lockParentField(field, value, label) {
        if (!field) return;
        if (value) field.value = value;
        field.readOnly = Boolean(value);
        field.classList.toggle('is-readonly', Boolean(value));
        field.placeholder = value ? `${label} from Client Group Master` : label;
    }

    function syncParentFieldsFromGroup(groupField, crpField, referredField) {
        if (!groupField) return;

        const parent = parentForGroup(groupField.value);
        const parentCrp = parent ? (parent.crp || '') : primaryCrpForGroup(groupField.value);
        const parentReferred = parent ? (parent.referred_by || '') : '';

        lockParentField(crpField, parentCrp, 'CRP of Group');
        lockParentField(referredField, parentReferred, 'Referred By');
    }

    function setupSearchableGroupSelect(select, input, options, onSelect) {
        if (!select || !input || !options) return;

        function filterOptions() {
            const searchText = input.value.trim().toLowerCase();
            options.querySelectorAll('.searchable-option').forEach(option => {
                option.style.display = option.textContent.toLowerCase().includes(searchText) ? "" : "none";
            });
        }

        function openOptions() {
            options.classList.add('is-open');
            filterOptions();
        }

        function closeOptions() {
            options.classList.remove('is-open');
        }

        input.addEventListener('focus', openOptions);
        input.addEventListener('click', openOptions);
        input.addEventListener('input', openOptions);

        options.querySelectorAll('.searchable-option').forEach(option => {
            option.addEventListener('click', () => {
                input.value = option.dataset.value || option.textContent.trim();
                if (onSelect) onSelect();
                closeOptions();
            });
        });

        document.addEventListener('click', event => {
            if (!select.contains(event.target)) closeOptions();
        });
    }

    setupSearchableGroupSelect(groupSelect, groupInput, groupOptions, () => {
        syncParentFieldsFromGroup(groupInput, crpInput, referredInput);
    });

    if (groupInput) {
        groupInput.addEventListener('input', () => {
            syncParentFieldsFromGroup(groupInput, crpInput, referredInput);
        });
    }

    const modal = document.getElementById('clientEditModal');
    const closeButton = document.getElementById('clientEditClose');
    const cancelButton = document.getElementById('clientEditCancel');

    function setValue(id, value) {
        const input = document.getElementById(id);
        if (input) input.value = value || '';
    }

    function openModal(row) {
        setValue('editClientId', row.dataset.clientId);
        setValue('editClientName', row.dataset.clientName);
        setValue('editClientGroup', row.dataset.clientGroup);
        setValue('editClientCategory', row.dataset.clientCategory);
        setValue('editCrpOfGroup', row.dataset.crpOfGroup);
        setValue('editRefferedBy', row.dataset.refferedBy);
        setValue('editWhatappGroup', row.dataset.whatappGroup);
        setValue('editPhone', row.dataset.phone);
        setValue('editEmail', row.dataset.email);
        setValue('editGstin', row.dataset.gstin);
        syncParentFieldsFromGroup(
            document.getElementById('editClientGroup'),
            document.getElementById('editCrpOfGroup'),
            document.getElementById('editRefferedBy')
        );
        document.getElementById('editClientName')?.dispatchEvent(new Event('blur'));
        modal.classList.add('is-open');
        modal.setAttribute('aria-hidden', 'false');
    }

    function closeModal() {
        if (!modal) return;
        modal.classList.remove('is-open');
        modal.setAttribute('aria-hidden', 'true');
    }

    document.querySelectorAll('.client-edit-btn').forEach(button => {
        button.addEventListener('click', () => {
            const row = button.closest('tr');
            if (row && modal) openModal(row);
        });
    });

    if (closeButton) closeButton.addEventListener('click', closeModal);
    if (cancelButton) cancelButton.addEventListener('click', closeModal);
    if (modal) {
        modal.addEventListener('click', event => {
            if (event.target === modal) closeModal();
        });
    }

    const editClientGroup = document.getElementById('editClientGroup');
    const editCrpOfGroup = document.getElementById('editCrpOfGroup');
    const editRefferedBy = document.getElementById('editRefferedBy');
    const editClientGroupSelect = document.getElementById('editClientGroupSelect');
    const editClientGroupOptions = document.getElementById('editClientGroupOptions');

    setupSearchableGroupSelect(editClientGroupSelect, editClientGroup, editClientGroupOptions, () => {
        syncParentFieldsFromGroup(editClientGroup, editCrpOfGroup, editRefferedBy);
    });

    if (editClientGroup) {
        editClientGroup.addEventListener('input', () => {
            syncParentFieldsFromGroup(editClientGroup, editCrpOfGroup, editRefferedBy);
        });
    }

    document.addEventListener('keydown', event => {
        if (event.key === 'Escape') closeModal();
    });

    const clientTable = document.getElementById('clientTable');
    if (!clientTable) return;

    const clientRows = Array.from(clientTable.querySelectorAll('tbody tr'));
    const clientNameIndex = new Map();

    function normalizeClientName(value) {
        return String(value || '').trim().replace(/\s+/g, ' ').toLowerCase();
    }

    clientRows.forEach(row => {
        const key = normalizeClientName(row.dataset.clientName);
        if (!key) return;
        clientNameIndex.set(key, {
            id: row.dataset.clientId || '',
            name: row.dataset.clientName || ''
        });
    });

    function setupClientDuplicateWarning(input, warning, submitButton, options = {}) {
        if (!input || !warning) return;
        let lastAlertKey = '';

        function checkDuplicate(showAlert) {
            const key = normalizeClientName(input.value);
            const ownId = String(options.ownId ? options.ownId() : '');
            const matchedClient = key ? clientNameIndex.get(key) : null;
            const isDuplicate = Boolean(matchedClient && String(matchedClient.id) !== ownId);

            input.classList.toggle('is-duplicate', isDuplicate);
            warning.hidden = !isDuplicate;
            warning.textContent = isDuplicate
                ? `Client already exists: ${matchedClient.name}`
                : '';

            if (submitButton) {
                submitButton.disabled = isDuplicate;
                submitButton.title = isDuplicate ? 'This client already exists.' : '';
            }

            if (isDuplicate && showAlert && lastAlertKey !== key) {
                lastAlertKey = key;
                alert(`Client already exists: ${matchedClient.name}`);
            } else if (!isDuplicate) {
                lastAlertKey = '';
            }

            return !isDuplicate;
        }

        input.addEventListener('input', () => checkDuplicate(true));
        input.addEventListener('blur', () => checkDuplicate(false));
        input.form?.addEventListener('submit', event => {
            if (!checkDuplicate(true)) {
                event.preventDefault();
                input.focus();
            }
        });

        checkDuplicate(false);
    }

    setupClientDuplicateWarning(
        document.getElementById('addClientName'),
        document.getElementById('addClientNameWarning'),
        document.getElementById('addClientSubmit')
    );

    setupClientDuplicateWarning(
        document.getElementById('editClientName'),
        document.getElementById('editClientNameWarning'),
        document.getElementById('editClientSubmit'),
        {
            ownId: () => document.getElementById('editClientId')?.value || ''
        }
    );

    const filterableColumns = [1, 2, 3, 4, 5];
    const activeFilters = {};
    const quickSearch = document.getElementById('clientQuickSearch');

    function filterClientTable() {
        const searchText = quickSearch ? quickSearch.value.trim().toLowerCase() : '';

        clientRows.forEach(row => {
            let isVisible = true;
            filterableColumns.forEach(cellIndex => {
                const selectedValues = activeFilters[cellIndex];
                if (!selectedValues || selectedValues.size === 0) return;

                const cellText = row.cells[cellIndex].textContent.trim();
                if (!selectedValues.has(cellText)) isVisible = false;
            });

            if (searchText && !row.textContent.toLowerCase().includes(searchText)) {
                isVisible = false;
            }

            row.style.display = isVisible ? "" : "none";
        });
    }

    if (quickSearch) {
        quickSearch.addEventListener('input', filterClientTable);
    }

    function updateFilterButton(button, cellIndex) {
        const selectedValues = activeFilters[cellIndex];
        const hasFilter = selectedValues && selectedValues.size > 0;
        button.classList.toggle('is-filtered', hasFilter);
        button.title = hasFilter ? `${selectedValues.size} selected` : 'Filter';
    }

    function setVisibleOptions(menu, searchText) {
        const term = searchText.trim().toLowerCase();
        menu.querySelectorAll('.filter-option').forEach(option => {
            option.style.display = option.textContent.toLowerCase().includes(term) ? "" : "none";
        });
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

    function buildClientFilter(th, cellIndex) {
        const label = th.textContent.trim();
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

        const menu = document.createElement('div');
        menu.className = 'filter-menu';

        const search = document.createElement('input');
        search.type = 'text';
        search.className = 'filter-search';
        search.placeholder = 'Search';

        const actions = document.createElement('div');
        actions.className = 'filter-actions';

        const selectAll = document.createElement('button');
        selectAll.type = 'button';
        selectAll.textContent = 'Select All';

        const clear = document.createElement('button');
        clear.type = 'button';
        clear.textContent = 'Clear';

        const ok = document.createElement('button');
        ok.type = 'button';
        ok.textContent = 'OK';

        const options = document.createElement('div');
        options.className = 'filter-options';

        const values = [...new Set(clientRows.map(row => row.cells[cellIndex].textContent.trim()))]
            .sort((a, b) => a.localeCompare(b, undefined, { numeric: true, sensitivity: 'base' }));

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

        selectAll.addEventListener('click', () => {
            options.querySelectorAll('.filter-option').forEach(option => {
                if (option.style.display !== 'none') {
                    option.querySelector('input').checked = true;
                }
            });
        });

        clear.addEventListener('click', () => {
            options.querySelectorAll('input').forEach(input => {
                input.checked = false;
            });
            activeFilters[cellIndex] = new Set();
        });

        ok.addEventListener('click', () => {
            activeFilters[cellIndex] = new Set(
                Array.from(options.querySelectorAll('input:checked')).map(input => input.value)
            );
            updateFilterButton(button, cellIndex);
            filterClientTable();
            menu.classList.remove('is-open');
        });

        search.addEventListener('input', () => setVisibleOptions(menu, search.value));

        button.addEventListener('click', event => {
            event.stopPropagation();
            document.querySelectorAll('.filter-menu.is-open').forEach(openMenu => {
                if (openMenu !== menu) openMenu.classList.remove('is-open');
            });
            menu.classList.toggle('is-open');
            if (menu.classList.contains('is-open')) {
                positionFilterMenu(button, menu);
                search.focus();
            }
        });

        menu.addEventListener('click', event => event.stopPropagation());

        actions.appendChild(selectAll);
        actions.appendChild(clear);
        actions.appendChild(ok);
        menu.appendChild(search);
        menu.appendChild(actions);
        menu.appendChild(options);
        wrapper.appendChild(labelSpan);
        wrapper.appendChild(button);
        wrapper.appendChild(menu);
        th.appendChild(wrapper);
    }

    filterableColumns.forEach(cellIndex => {
        const th = clientTable.tHead.rows[0].cells[cellIndex];
        if (th) buildClientFilter(th, cellIndex);
    });

    document.addEventListener('click', () => {
        document.querySelectorAll('.filter-menu.is-open').forEach(menu => {
            menu.classList.remove('is-open');
        });
    });

    window.addEventListener('resize', () => {
        document.querySelectorAll('.filter-menu.is-open').forEach(menu => {
            menu.classList.remove('is-open');
        });
    });

    document.querySelector('main')?.addEventListener('scroll', () => {
        document.querySelectorAll('.filter-menu.is-open').forEach(menu => {
            menu.classList.remove('is-open');
        });
    });
});
