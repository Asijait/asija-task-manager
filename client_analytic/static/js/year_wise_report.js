(function () {
    const table = document.getElementById('yearWiseReportTable');
    if (!table) return;

    const rows = Array.from(table.querySelectorAll('tbody tr[data-search]'));
    const searchInput = document.getElementById('yearWiseSearch');
    const yearFilter = document.getElementById('yearWiseYearFilter');
    const typeFilter = document.getElementById('yearWiseTypeFilter');
    const sourceFilter = document.getElementById('yearWiseSourceFilter');
    const clearButton = document.getElementById('clearYearWiseFilters');
    const visibleCount = document.getElementById('visibleRecordCount');

    function normalize(value) {
        return String(value || '').trim().toLowerCase();
    }

    function applyFilters() {
        const search = normalize(searchInput && searchInput.value);
        const year = yearFilter ? yearFilter.value : '';
        const type = typeFilter ? typeFilter.value : '';
        const source = sourceFilter ? sourceFilter.value : '';
        let shown = 0;

        rows.forEach(function (row) {
            const matchesSearch = !search || normalize(row.dataset.search).includes(search);
            const matchesYear = !year || row.dataset.year === year;
            const matchesType = !type || row.dataset.type === type;
            const matchesSource = !source || row.dataset.source === source;
            const isVisible = matchesSearch && matchesYear && matchesType && matchesSource;
            row.hidden = !isVisible;
            if (isVisible) shown += 1;
        });

        if (visibleCount) visibleCount.textContent = shown;
    }

    [searchInput, yearFilter, typeFilter, sourceFilter].forEach(function (control) {
        if (!control) return;
        control.addEventListener('input', applyFilters);
        control.addEventListener('change', applyFilters);
    });

    if (clearButton) {
        clearButton.addEventListener('click', function () {
            if (searchInput) searchInput.value = '';
            if (yearFilter) yearFilter.value = '';
            if (typeFilter) typeFilter.value = '';
            if (sourceFilter) sourceFilter.value = '';
            applyFilters();
        });
    }

    applyFilters();
}());
