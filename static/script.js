// ==================== Utility Functions ====================

function formatDate(dateStr) {
    if (!dateStr) return 'No Target Date Set';
    try {
        const date = new Date(dateStr + 'T00:00:00');
        if (isNaN(date.getTime())) return dateStr;
        return date.toLocaleDateString('en-IN', { year: 'numeric', month: 'short', day: 'numeric' });
    } catch (e) {
        return dateStr;
    }
}

function getDaySuffix(day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
        case 1: return 'st';
        case 2: return 'nd';
        case 3: return 'rd';
        default: return 'th';
    }
}

function getScheduleDescription(work) {
    if (!work.work_date) return 'No Target Date Set';
    const date = new Date(work.work_date + 'T00:00:00');
    if (isNaN(date.getTime())) return work.work_date;
    
    const day = date.getDate();
    const suffix = getDaySuffix(day);
    const month = date.toLocaleString('en-IN', { month: 'long' });
    const weekday = date.toLocaleString('en-IN', { weekday: 'long' });

    switch(work.work_tat) {
        case 'daily': return 'Every Day';
        case 'weekly': return `${weekday} every week`;
        case 'monthly': return `${day}${suffix} every month`;
        case 'quarterly': return `${day}${suffix} every quarter`;
        case 'yearly': return `${day}${suffix} ${month} every year`;
        case 'once': return `Once: ${formatDate(work.work_date)}`;
        case 'ongoing': return 'Ongoing';
        default: return formatDate(work.work_date);
    }
}

function capitalize(str) {
    if (!str) return '';
    return str.charAt(0).toUpperCase() + str.slice(1);
}

function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function formatDateForAPI(date) {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
}

// ==================== Error Handling ====================

function showError(message) {
    console.error(message);
    alert(message);
}

function handleApiError(error) {
    console.error('API Error:', error);
    return error.message || 'An error occurred';
}

// ==================== Local Storage Helpers ====================

function saveToLocalStorage(key, value) {
    try {
        localStorage.setItem(key, JSON.stringify(value));
    } catch (e) {
        console.error('LocalStorage error:', e);
    }
}

function getFromLocalStorage(key, defaultValue = null) {
    try {
        const item = localStorage.getItem(key);
        return item ? JSON.parse(item) : defaultValue;
    } catch (e) {
        console.error('LocalStorage error:', e);
        return defaultValue;
    }
}

// ==================== Notification System ====================

function showNotification(message, type = 'info', duration = 3000) {
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;
    
    // Add to body if not already present
    if (!document.querySelector('.notifications-container')) {
        const container = document.createElement('div');
        container.className = 'notifications-container';
        document.body.appendChild(container);
    }
    
    const container = document.querySelector('.notifications-container');
    container.appendChild(notification);
    
    // Auto remove after duration
    setTimeout(() => {
        notification.remove();
    }, duration);
}

// ==================== Date Range Functions ====================

function getDatesInRange(startDate, endDate) {
    const dates = [];
    const currentDate = new Date(startDate);
    
    while (currentDate <= endDate) {
        dates.push(new Date(currentDate));
        currentDate.setDate(currentDate.getDate() + 1);
    }
    
    return dates;
}

function getMonthDates(date) {
    const year = date.getFullYear();
    const month = date.getMonth();
    
    return getDatesInRange(
        new Date(year, month, 1),
        new Date(year, month + 1, 0)
    );
}

// ==================== Export/Import Functions ====================

function exportDataAsJSON() {
    Promise.all([
        fetch('/api/works').then(r => r.json()),
        fetch('/api/assigned/all').then(r => r.json()).catch(() => [])
    ]).then(([works, assigned]) => {
        const data = {
            timestamp: new Date().toISOString(),
            works,
            assigned
        };
        
        const dataStr = JSON.stringify(data, null, 2);
        const dataBlob = new Blob([dataStr], { type: 'application/json' });
        const url = URL.createObjectURL(dataBlob);
        const link = document.createElement('a');
        link.href = url;
        link.download = `task-data-${new Date().toISOString().split('T')[0]}.json`;
        link.click();
        URL.revokeObjectURL(url);
    }).catch(error => {
        console.error('Export error:', error);
        alert('Error exporting data');
    });
}

// ==================== Validation Functions ====================

function validateEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
}

/**
 * Updated validation to support conditional fields for different frequencies
 */
function validateWorkForm(workName, workTat, dayOfMonth, workDate, workStartDate) {
    if (!workName || !workName.trim()) {
        showError('Work name is required');
        return false;
    }
    
    if (!workTat) {
        showError('Frequency is required');
        return false;
    }

    if (!workDate) {
        showError('A target date is required for all tasks');
        return false;
    }
    
    return true;
}

// ==================== Advanced Filtering ====================

function filterWorksByTat(works, tat) {
    return works.filter(work => work.work_tat === tat);
}

function filterWorksByDateRange(works, startDate, endDate) {
    return works.filter(work => {
        // If it's ongoing and has no specific date, include it in all ranges
        if (work.work_tat === 'ongoing' && !work.work_date) return true;
        
        const dueDate = new Date(work.work_date);
        return isNaN(dueDate.getTime()) || (dueDate >= startDate && dueDate <= endDate);
    });
}

function searchWorks(works, searchTerm) {
    const term = searchTerm.toLowerCase();
    return works.filter(work => 
        work.work_name.toLowerCase().includes(term)
    );
}

// ==================== Statistics Functions ====================

async function getWorkStatistics() {
    try {
        const works = await fetch('/api/works').then(r => r.json());
        
        return {
            total: works.length,
            byTat: {
                daily: works.filter(w => w.work_tat === 'daily').length,
                weekly: works.filter(w => w.work_tat === 'weekly').length,
                monthly: works.filter(w => w.work_tat === 'monthly').length,
                quarterly: works.filter(w => w.work_tat === 'quarterly').length,
                yearly: works.filter(w => w.work_tat === 'yearly').length,
                once: works.filter(w => w.work_tat === 'once').length,
                ongoing: works.filter(w => w.work_tat === 'ongoing').length
            }
        };
    } catch (error) {
        console.error('Error getting statistics:', error);
        return null;
    }
}

// ==================== Print Functions ====================

function printWorkList() {
    const printWindow = window.open('', '', 'height=600,width=800');
    
    fetch('/api/works')
        .then(r => r.json())
        .then(works => {
            let htmlContent = `
                <html>
                <head>
                    <title>Work Master - Print</title>
                    <style>
                        body { font-family: Arial, sans-serif; margin: 20px; }
                        table { width: 100%; border-collapse: collapse; }
                        th, td { border: 1px solid #ddd; padding: 10px; text-align: left; }
                        th { background: #1f5f93; color: white; }
                        tr:nth-child(even) { background: #f9f9f9; }
                    </style>
                </head>
                <body>
                    <h1>Work Master Report</h1>
                    <p>Generated: ${new Date().toLocaleString()}</p>
                    <table>
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Work Name</th>
                                <th>Schedule</th>
                                <th>Frequency</th>
                            </tr>
                        </thead>
                        <tbody>
            `;
            
            works.forEach((work, index) => {
                htmlContent += `
                    <tr>
                        <td>${index + 1}</td>
                        <td>${escapeHtml(work.work_name)}</td>
                        <td>${getScheduleDescription(work)}</td>
                        <td>${capitalize(work.work_tat)}</td>
                    </tr>
                `;
            });
            
            htmlContent += `
                        </tbody>
                    </table>
                </body>
                </html>
            `;
            
            printWindow.document.write(htmlContent);
            printWindow.document.close();
            
            setTimeout(() => {
                printWindow.print();
            }, 250);
        })
        .catch(error => {
            console.error('Print error:', error);
            printWindow.close();
        });
}

// ==================== Event Listeners (Global) ====================

document.addEventListener('DOMContentLoaded', function() {
    // Keyboard shortcuts
    document.addEventListener('keydown', function(event) {
        // Ctrl+E or Cmd+E to export
        if ((event.ctrlKey || event.metaKey) && event.key === 'e') {
            event.preventDefault();
            exportDataAsJSON();
        }
        
        // Ctrl+P or Cmd+P for print (handled by browser by default)
        // Ctrl+N or Cmd+N to create new (can be extended)
        if ((event.ctrlKey || event.metaKey) && event.key === 'n') {
            event.preventDefault();
            // Trigger new work form focus if on work-master page
            const workForm = document.getElementById('workForm');
            if (workForm) {
                document.getElementById('workName').focus();
            }
        }
    });

    // Add logout confirmation listener
    document.addEventListener('click', function(event) {
        const logoutBtn = event.target.closest('.nav-btn-logout');
        if (logoutBtn) {
            if (!confirm('Are you sure you want to log out?')) {
                event.preventDefault();
            }
        }
    });
    
    // Disable right-click context menu on sensitive elements (optional)
    // document.addEventListener('contextmenu', (e) => e.preventDefault());
});

// ==================== Performance Monitoring ====================

function logPerformance() {
    if (window.performance && window.performance.timing) {
        const perfData = window.performance.timing;
        const pageLoadTime = perfData.loadEventEnd - perfData.navigationStart;
        console.log('Page Load Time: ' + pageLoadTime + 'ms');
    }
}

window.addEventListener('load', logPerformance);

// ==================== Custom Styles for Notifications ====================

if (!document.querySelector('style[data-notifications]')) {
    const style = document.createElement('style');
    style.setAttribute('data-notifications', 'true');
    style.textContent = `
        .notifications-container {
            font-family: 'Times New Roman', Times, serif;
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 9999;
            max-width: 400px;
        }
        
        .notification {
            background: white;
            padding: 15px 20px;
            margin-bottom: 10px;
            border-radius: 8px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
            animation: slideInRight 0.3s ease-out;
            border-left: 4px solid #9fd0ff;
        }
        
        .notification-success {
            border-left-color: #28a745;
            background: #d4edda;
            color: #155724;
        }
        
        .notification-error {
            border-left-color: #dc3545;
            background: #f8d7da;
            color: #721c24;
        }
        
        .notification-info {
            border-left-color: #17a2b8;
            background: #d1ecf1;
            color: #0c5460;
        }
        
        .notification-warning {
            border-left-color: #ffc107;
            background: #fff3cd;
            color: #856404;
        }
        
        @keyframes slideInRight {
            from {
                opacity: 0;
                transform: translateX(300px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }
    `;
    document.head.appendChild(style);
}
