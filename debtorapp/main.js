document.addEventListener('DOMContentLoaded', function() {
    console.log("Billing Report Application Initialized");
    
    // Example: Highlight rows that are significantly overdue
    const rows = document.querySelectorAll('#reportTable tbody tr');
    rows.forEach(row => {
        const daysCell = row.querySelector('.days-cell');
        if (daysCell && parseInt(daysCell.textContent) > 60) row.style.fontWeight = 'bold';
    });

    // Auto-hide flash messages after 2 seconds
    const flashMessages = document.querySelectorAll('.flash-message');
    flashMessages.forEach(msg => {
        setTimeout(() => {
            msg.style.opacity = '0';
            setTimeout(() => msg.remove(), 500);
        }, 2000);
    });
});