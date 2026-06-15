document.addEventListener('DOMContentLoaded', () => {
    loadAssignees();

    document.getElementById('assigneeForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const name = document.getElementById('assigneeName').value;

        const response = await fetch('/api/assignees', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ name })
        });

        if (response.ok) {
            document.getElementById('assigneeName').value = '';
            loadAssignees();
            if(window.showNotification) showNotification('Assignee added!', 'success');
        } else {
            const err = await response.json();
            alert(err.error);
        }
    });
});

async function loadAssignees() {
    const response = await fetch('/api/assignees');
    const data = await response.json();
    const tbody = document.getElementById('assigneeTableBody');
    tbody.innerHTML = '';

    data.forEach((item, index) => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td class="col-id">${index + 1}</td>
            <td>${item.name}</td>
            <td>
                <button onclick="openEditModal(${item.id}, '${item.name}')" class="btn-icon">✏️</button>
                <button onclick="deleteAssignee(${item.id})" class="btn-icon">❌</button>
            </td>
        `;
        tbody.appendChild(row);
    });
}

function openEditModal(id, name) {
    document.getElementById('editAssigneeId').value = id;
    document.getElementById('editAssigneeName').value = name;
    document.getElementById('editAssigneeModal').style.display = 'flex';
}

function closeModal() {
    document.getElementById('editAssigneeModal').style.display = 'none';
}

async function updateAssignee() {
    const id = document.getElementById('editAssigneeId').value;
    const name = document.getElementById('editAssigneeName').value;

    const response = await fetch(`/api/assignees/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name })
    });

    if (response.ok) {
        closeModal();
        loadAssignees();
        if(window.showNotification) showNotification('Updated successfully!', 'success');
    } else {
        const err = await response.json();
        alert(err.error);
    }
}

async function deleteAssignee(id) {
    if (!confirm('Are you sure you want to delete this master entry?')) return;

    const response = await fetch(`/api/assignees/${id}`, {
        method: 'DELETE'
    });

    if (response.ok) {
        loadAssignees();
        if(window.showNotification) showNotification('Deleted!', 'info');
    }
}

// Handle logout functionality
function handleLogout() {
    if (!confirm('Are you sure you want to logout?')) {
        return;
    }
    sessionStorage.clear();
    localStorage.clear();
    history.replaceState(null, null, window.location.href);
    window.location.href = '/logout';
}

// Prevent back navigation after page load
window.addEventListener('load', function() {
    history.pushState(null, null, location.href);
    window.onpopstate = function() {
        history.go(1);
    };
});

// Redirect if accessed via browser back button
window.addEventListener('pageshow', function(event) {
    if (event.persisted) {
        window.location.href = '/login';
    }
});