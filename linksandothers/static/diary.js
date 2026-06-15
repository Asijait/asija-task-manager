let selectedFilterDate = null;
const currentDisplayDate = new Date();

document.addEventListener('DOMContentLoaded', () => {
    // Load existing records from database
    fetch('/get_diary')
        .then(res => res.json())
        .then(data => {
            if (data && data.length > 0) {
                // Add rows to the table; since data is ordered by ID ASC from backend,
                // prepending each will result in the newest entry appearing at the top.
                data.forEach(item => addRow(item));
            } else {
                addRow(); // Start with one empty row if DB is empty
            }
            initCalendar();
        });
});

/**
 * Initializes the month picker and renders the calendar
 */
function initCalendar() {
    const monthPicker = document.getElementById('monthPicker');
    const now = new Date();
    
    if (!monthPicker.value) {
        const monthStr = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
        monthPicker.value = monthStr;
    }

    monthPicker.addEventListener('change', (e) => {
        renderCalendar(e.target.value);
    });

    renderCalendar(monthPicker.value);
}

/**
 * Renders the calendar grid based on selected month
 */
function renderCalendar(monthYearStr) {
    const [year, month] = monthYearStr.split('-').map(Number);
    const container = document.getElementById('calendarContainer');
    container.innerHTML = '';

    const daysInWeek = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    daysInWeek.forEach(day => {
        const div = document.createElement('div');
        div.className = 'calendar-header-day';
        div.innerText = day;
        container.appendChild(div);
    });

    const firstDay = new Date(year, month - 1, 1).getDay();
    const totalDays = new Date(year, month, 0).getDate();

    // Padding for first week
    for (let i = 0; i < firstDay; i++) {
        const div = document.createElement('div');
        div.className = 'calendar-date-cell empty';
        container.appendChild(div);
    }

    for (let day = 1; day <= totalDays; day++) {
        const div = document.createElement('div');
        div.className = 'calendar-date-cell';
        div.innerText = day;
        
        const dateStr = `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
        if (selectedFilterDate === dateStr) div.classList.add('active');

        div.onclick = () => filterByDate(dateStr);
        container.appendChild(div);
    }
}

/**
 * Adds a new entry row to the table
 */
function addRow(data = {}) {
    const tbody = document.getElementById('diaryBody');
    const row = document.createElement('tr');
    // If filtered, default new row to that date
    const today = selectedFilterDate || new Date().toISOString().split('T')[0];

    row.innerHTML = `
        <td><input type="date" class="d-date" value="${data.entry_date || today}"></td>
        <td><textarea class="d-particulars" placeholder="Details of work...">${data.particulars || ''}</textarea></td>
        <td><input type="text" class="d-start" value="${data.start_t || ''}" placeholder="12:00 AM"></td>
        <td><input type="text" class="d-end" value="${data.end_t || ''}" placeholder="12:00 PM"></td>
        <td><input type="text" class="d-time" placeholder="Total Hrs" value="${data.spend_time || ''}" readonly></td>
        <td><textarea class="d-remark" placeholder="Remarks...">${data.remark || ''}</textarea></td>
        <td style="text-align:center"><button class="btn-del" onclick="this.closest('tr').remove()">×</button></td>
    `;
    // Prepend puts the newest entry at the top
    tbody.prepend(row);

    // Initialize Analog Clock Picker
    const startInput = row.querySelector('.d-start');
    const endInput = row.querySelector('.d-end');
    
    // Single click for typing: standard behavior (input is not readonly)
    // Double click to open the analog clock picker
    mdtimepicker(startInput, { 
        is24hour: false, 
        format: 'hh:mm tt',
        hourPadding: true,
        events: { timeChanged: () => calcTime(startInput) } 
    });
    mdtimepicker(endInput, { 
        is24hour: false, 
        format: 'hh:mm tt',
        hourPadding: true,
        events: { timeChanged: () => calcTime(endInput) } 
    });

    startInput.addEventListener('dblclick', () => { mdtimepicker(startInput, 'show'); });
    endInput.addEventListener('dblclick', () => { mdtimepicker(endInput, 'show'); });

    startInput.addEventListener('input', () => calcTime(startInput));
    endInput.addEventListener('input', () => calcTime(endInput));
}

/**
 * Filters the table by selected date
 */
function filterByDate(dateStr) {
    selectedFilterDate = dateStr;
    const rows = document.querySelectorAll('#diaryBody tr');
    
    rows.forEach(row => {
        const rowDate = row.querySelector('.d-date').value;
        row.style.display = (rowDate === dateStr) ? '' : 'none';
    });

    // Update UI active state in calendar
    document.querySelectorAll('.calendar-date-cell').forEach(cell => cell.classList.remove('active'));
    renderCalendar(document.getElementById('monthPicker').value); // Re-render to show active state
}

/**
 * Clears the date filter
 */
function clearFilter() {
    selectedFilterDate = null;
    document.querySelectorAll('#diaryBody tr').forEach(row => row.style.display = '');
    renderCalendar(document.getElementById('monthPicker').value);
}

/**
 * Calculates the time difference in decimal hours
 */
function calcTime(input) {
    const row = input.closest('tr');
    const start = row.querySelector('.d-start').value;
    const end = row.querySelector('.d-end').value;
    
    const startMin = parse12hToMinutes(start);
    const endMin = parse12hToMinutes(end);

    if (startMin !== null && endMin !== null) {
        let diff = (endMin - startMin) / 60;
        if (diff < 0) diff += 24; // Handle overnight shift
        row.querySelector('.d-time').value = diff.toFixed(2) + " hrs";
    }
}

/**
 * Helper to parse 12-hour string (hh:mm AM/PM) into total minutes
 */
function parse12hToMinutes(timeStr) {
    if (!timeStr) return null;
    const match = timeStr.match(/^(\d{1,2}):(\d{2})\s*(AM|PM)$/i);
    if (!match) return null;

    let hours = parseInt(match[1], 10);
    const minutes = parseInt(match[2], 10);
    const ampm = match[3].toUpperCase();

    if (ampm === 'PM' && hours < 12) hours += 12;
    if (ampm === 'AM' && hours === 12) hours = 0;
    return hours * 60 + minutes;
}

/**
 * Saves all rows to the SQLite database
 */
function saveAll() {
    const rows = document.querySelectorAll('#diaryBody tr');
    const data = Array.from(rows).map(row => ({
        date: row.querySelector('.d-date').value,
        particulars: row.querySelector('.d-particulars').value,
        start_t: row.querySelector('.d-start').value,
        end_t: row.querySelector('.d-end').value,
        spend_time: row.querySelector('.d-time').value,
        remark: row.querySelector('.d-remark').value
    }));

    fetch('/save_diary', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    })
    .then(res => res.json())
    .then(res => {
        if (res.status === 'success') {
            alert("✅ Daily Diary updated successfully!");
        } else {
            alert("❌ Error saving: " + res.message);
        }
    });
}

/**
 * Generates an Excel file from the current table data
 */
function exportDiary() {
    const rows = document.querySelectorAll('#diaryBody tr');
    if (rows.length === 0) return alert("No records to export!");

    const exportData = Array.from(rows).map((row, i) => ({
        "Sl No": i + 1,
        "Date": row.querySelector('.d-date').value,
        "Particulars": row.querySelector('.d-particulars').value,
        "Start": row.querySelector('.d-start').value,
        "End": row.querySelector('.d-end').value,
        "Total Spend Time": row.querySelector('.d-time').value,
        "Remark": row.querySelector('.d-remark').value
    }));

    const ws = XLSX.utils.json_to_sheet(exportData);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "WorkDiary");
    XLSX.writeFile(wb, `Daily_Work_Diary_${new Date().toLocaleDateString()}.xlsx`);
}

/**
 * Toggles the calendar sidebar visibility
 */
function toggleSidebar() {
    const sidebar = document.getElementById('calendarSidebar');
    const content = document.getElementById('diaryContent');
    const btn = document.getElementById('sidebarToggle');

    sidebar.classList.toggle('collapsed');
    content.classList.toggle('expanded');

    if (sidebar.classList.contains('collapsed')) {
        btn.classList.add('collapsed-btn');
        btn.innerHTML = "≫";
    } else {
        btn.classList.remove('collapsed-btn');
        btn.innerHTML = "☰";
    }
}