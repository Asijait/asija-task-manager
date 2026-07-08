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
    const addModal = document.getElementById('clientAddModal');
    const addCloseButton = document.getElementById('clientAddClose');
    const addCancelButton = document.getElementById('clientAddCancel');

    function openClientAddModal() {
        if (!addModal) return;
        addModal.classList.add('is-open');
        addModal.setAttribute('aria-hidden', 'false');
        const firstInput = document.getElementById('addClientName') || addModal.querySelector('input, select, button');
        if (firstInput) firstInput.focus();
    }

    function closeClientAddModal() {
        if (!addModal) return;
        addModal.classList.remove('is-open');
        addModal.setAttribute('aria-hidden', 'true');
    }

    if (showFormButton) {
        showFormButton.addEventListener('click', () => {
            openClientAddModal();
        });
    }

    if (addCloseButton) addCloseButton.addEventListener('click', closeClientAddModal);
    if (addCancelButton) addCancelButton.addEventListener('click', closeClientAddModal);
    if (addModal) {
        addModal.addEventListener('click', event => {
            if (event.target === addModal) closeClientAddModal();
        });
    }

    const groupSelect = document.getElementById('clientGroupSelect');
    const groupInput = document.getElementById('clientGroupInput');
    const groupOptions = document.getElementById('clientGroupOptions');
    const crpSelect = document.getElementById('clientCrpSelect');
    const crpInput = document.getElementById('clientCrpInput');
    const crpOptions = document.getElementById('clientCrpOptions');
    const categorySelect = document.getElementById('clientCategorySelect');
    const categoryInput = document.getElementById('clientCategoryInput');
    const categoryOptions = document.getElementById('clientCategoryOptions');
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

    function setupSearchableSelect(select, input, options, onSelect) {
        if (!select || !input || !options) return;

        function filterOptions() {
            const searchText = input.value.trim().toLowerCase();
            options.querySelectorAll('.searchable-option').forEach(option => {
                option.style.display = option.textContent.toLowerCase().includes(searchText) ? "" : "none";
            });
        }

        function openOptions() {
            if (input.readOnly) return;
            options.classList.add('is-open');
            filterOptions();
        }

        function closeOptions() {
            options.classList.remove('is-open');
            markActiveOption(-1);
        }

        let activeOptionIndex = -1;

        function visibleOptionButtons() {
            return Array.from(options.querySelectorAll('.searchable-option'))
                .filter(option => option.style.display !== 'none');
        }

        function markActiveOption(index) {
            const visibleOptions = visibleOptionButtons();
            options.querySelectorAll('.searchable-option').forEach(option => {
                option.classList.remove('is-active');
            });
            if (!visibleOptions.length || index < 0) {
                activeOptionIndex = -1;
                return;
            }

            activeOptionIndex = Math.max(0, Math.min(index, visibleOptions.length - 1));
            if (activeOptionIndex >= 0) {
                visibleOptions[activeOptionIndex].classList.add('is-active');
                visibleOptions[activeOptionIndex].scrollIntoView({ block: 'nearest' });
            }
        }

        function selectOption(option, keepFocus) {
            input.value = option.dataset.value || option.textContent.trim();
            if (onSelect) onSelect();
            closeOptions();
            if (keepFocus) input.focus();
        }

        input.addEventListener('focus', openOptions);
        input.addEventListener('click', openOptions);
        input.addEventListener('input', () => {
            activeOptionIndex = -1;
            openOptions();
        });
        input.addEventListener('keydown', event => {
            if (!['ArrowDown', 'ArrowUp', 'Enter', 'Tab'].includes(event.key)) return;
            if (input.readOnly) return;
            if (!options.classList.contains('is-open')) openOptions();
            const visibleOptions = visibleOptionButtons();
            if (!visibleOptions.length) return;

            if (event.key === 'ArrowDown' && event.altKey) {
                event.preventDefault();
                markActiveOption(activeOptionIndex >= 0 ? activeOptionIndex : 0);
            } else if (event.key === 'ArrowDown') {
                event.preventDefault();
                markActiveOption(activeOptionIndex + 1);
            } else if (event.key === 'ArrowUp') {
                event.preventDefault();
                markActiveOption(activeOptionIndex <= 0 ? visibleOptions.length - 1 : activeOptionIndex - 1);
            } else if (event.key === 'Enter' && activeOptionIndex >= 0) {
                event.preventDefault();
                selectOption(visibleOptions[activeOptionIndex], true);
            } else if (event.key === 'Tab' && activeOptionIndex >= 0) {
                selectOption(visibleOptions[activeOptionIndex], false);
            }
        });

        options.querySelectorAll('.searchable-option').forEach(option => {
            option.addEventListener('click', () => {
                selectOption(option, true);
            });
        });

        document.addEventListener('click', event => {
            if (!select.contains(event.target)) closeOptions();
        });
    }

    setupSearchableSelect(groupSelect, groupInput, groupOptions, () => {
        syncParentFieldsFromGroup(groupInput, crpInput, referredInput);
    });
    setupSearchableSelect(crpSelect, crpInput, crpOptions);
    setupSearchableSelect(categorySelect, categoryInput, categoryOptions);

    if (groupInput) {
        groupInput.addEventListener('input', () => {
            syncParentFieldsFromGroup(groupInput, crpInput, referredInput);
        });
    }

    const modal = document.getElementById('clientEditModal');
    const closeButton = document.getElementById('clientEditClose');
    const cancelButton = document.getElementById('clientEditCancel');
    const choiceModal = document.getElementById('clientChoiceModal');
    const choiceName = document.getElementById('clientChoiceName');
    const choiceClose = document.getElementById('clientChoiceClose');
    const choiceView = document.getElementById('clientChoiceView');
    const choiceEdit = document.getElementById('clientChoiceEdit');
    const viewModal = document.getElementById('clientViewModal');
    const viewClose = document.getElementById('clientViewClose');
    const viewOk = document.getElementById('clientViewOk');
    const viewGrid = document.getElementById('clientViewGrid');
    let selectedClientRow = null;

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

    function closeChoiceModal() {
        if (!choiceModal) return;
        choiceModal.classList.remove('is-open');
        choiceModal.setAttribute('aria-hidden', 'true');
    }

    function openChoiceModal(row) {
        selectedClientRow = row;
        if (!choiceModal) return;
        if (choiceName) choiceName.textContent = row.dataset.clientName || 'Selected client';
        choiceModal.classList.add('is-open');
        choiceModal.setAttribute('aria-hidden', 'false');
        choiceView?.focus();
    }

    function closeViewModal() {
        if (!viewModal) return;
        viewModal.classList.remove('is-open');
        viewModal.setAttribute('aria-hidden', 'true');
    }

    function openViewModal(row) {
        if (!viewModal || !viewGrid) return;
        const fields = [
            ['Client Name', row.dataset.clientName],
            ['Group', row.dataset.clientGroup],
            ['CRP', row.dataset.crpOfGroup],
            ['Category', row.dataset.clientCategory],
            ['Referred By', row.dataset.refferedBy],
            ['WhatsApp Group', row.dataset.whatappGroup],
            ['Phone', row.dataset.phone],
            ['Email', row.dataset.email],
            ['GSTIN', row.dataset.gstin]
        ];

        viewGrid.innerHTML = '';
        fields.forEach(([label, value]) => {
            const term = document.createElement('dt');
            const detail = document.createElement('dd');
            term.textContent = label;
            detail.textContent = value || '-';
            viewGrid.appendChild(term);
            viewGrid.appendChild(detail);
        });

        viewModal.classList.add('is-open');
        viewModal.setAttribute('aria-hidden', 'false');
        viewOk?.focus();
    }

    document.querySelectorAll('.client-edit-btn').forEach(button => {
        button.addEventListener('click', () => {
            const row = button.closest('tr');
            if (row && modal) openModal(row);
        });
    });

    if (closeButton) closeButton.addEventListener('click', closeModal);
    if (cancelButton) cancelButton.addEventListener('click', closeModal);
    if (choiceClose) choiceClose.addEventListener('click', closeChoiceModal);
    if (choiceView) {
        choiceView.addEventListener('click', () => {
            if (selectedClientRow) openViewModal(selectedClientRow);
            closeChoiceModal();
        });
    }
    if (choiceEdit) {
        choiceEdit.addEventListener('click', () => {
            if (selectedClientRow && modal) openModal(selectedClientRow);
            closeChoiceModal();
        });
    }
    if (viewClose) viewClose.addEventListener('click', closeViewModal);
    if (viewOk) viewOk.addEventListener('click', closeViewModal);
    if (modal) {
        modal.addEventListener('click', event => {
            if (event.target === modal) closeModal();
        });
    }
    if (choiceModal) {
        choiceModal.addEventListener('click', event => {
            if (event.target === choiceModal) closeChoiceModal();
        });
    }
    if (viewModal) {
        viewModal.addEventListener('click', event => {
            if (event.target === viewModal) closeViewModal();
        });
    }

    const editClientGroup = document.getElementById('editClientGroup');
    const editClientCategory = document.getElementById('editClientCategory');
    const editCrpOfGroup = document.getElementById('editCrpOfGroup');
    const editRefferedBy = document.getElementById('editRefferedBy');
    const editClientGroupSelect = document.getElementById('editClientGroupSelect');
    const editClientGroupOptions = document.getElementById('editClientGroupOptions');
    const editCrpSelect = document.getElementById('editCrpSelect');
    const editCrpOptions = document.getElementById('editCrpOptions');
    const editClientCategorySelect = document.getElementById('editClientCategorySelect');
    const editClientCategoryOptions = document.getElementById('editClientCategoryOptions');

    setupSearchableSelect(editClientGroupSelect, editClientGroup, editClientGroupOptions, () => {
        syncParentFieldsFromGroup(editClientGroup, editCrpOfGroup, editRefferedBy);
    });
    setupSearchableSelect(editCrpSelect, editCrpOfGroup, editCrpOptions);
    setupSearchableSelect(editClientCategorySelect, editClientCategory, editClientCategoryOptions);

    if (editClientGroup) {
        editClientGroup.addEventListener('input', () => {
            syncParentFieldsFromGroup(editClientGroup, editCrpOfGroup, editRefferedBy);
        });
    }

    function setupArrowFieldNavigation(container) {
        if (!container) return;
        container.addEventListener('keydown', event => {
            if (!['ArrowDown', 'ArrowUp'].includes(event.key)) return;
            if (event.target.closest('.searchable-select')) return;

            const focusables = Array.from(container.querySelectorAll('input, select, button'))
                .filter(element => !element.disabled && element.offsetParent !== null);
            const currentIndex = focusables.indexOf(event.target);
            if (currentIndex === -1) return;

            event.preventDefault();
            const nextIndex = event.key === 'ArrowDown'
                ? Math.min(currentIndex + 1, focusables.length - 1)
                : Math.max(currentIndex - 1, 0);
            focusables[nextIndex]?.focus();
        });
    }

    setupArrowFieldNavigation(addModal);
    setupArrowFieldNavigation(modal);
    setupArrowFieldNavigation(choiceModal);
    setupArrowFieldNavigation(viewModal);

    document.addEventListener('keydown', event => {
        if (event.key !== 'Escape') return;
        closeClientAddModal();
        closeChoiceModal();
        closeViewModal();
        closeModal();
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
        row.tabIndex = 0;
        row.addEventListener('dblclick', () => openChoiceModal(row));
        row.addEventListener('keydown', event => {
            if (event.key === 'Enter') openChoiceModal(row);
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

    const filterableColumns = [0, 1, 2, 3, 4];
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
