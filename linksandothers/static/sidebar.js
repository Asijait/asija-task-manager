// --- SIDEBAR CONFIG ---
const PORT_SIDEBAR = "5001";

// 1. Sidebar Toggle Logic
document.getElementById('sidebarToggle').addEventListener('click', function () {
    const sidebar = document.getElementById('mySidebar');
    const content = document.querySelector('.content-area');

    sidebar.classList.toggle('collapsed');
    if (content) content.classList.toggle('expanded');

    // Icon Change
    this.innerHTML = sidebar.classList.contains('collapsed') ? "≫" : "☰";
});

// 3. Link Category Check (New Category Input)
function checkNewCat(select) {
    const newCatInput = document.getElementById('newCatInput');
    if (select.value === "NEW") {
        newCatInput.style.display = "block";
        newCatInput.required = true;
        newCatInput.name = "category";
        select.name = ""; 
    } else {
        newCatInput.style.display = "none";
        newCatInput.required = false;
        newCatInput.name = ""; 
        select.name = "category";
    }
}

// 4. Sidebar Link Edit Modal
function openEditModal(id, category, name, url, isSpecial) {
    document.getElementById('edit_id').value = id;
    document.getElementById('edit_cat').value = category;
    document.getElementById('edit_name').value = name;
    document.getElementById('edit_url').value = url;
    document.getElementById('edit_special').checked = isSpecial;
    document.getElementById('editModal').style.display = 'block';
}

// 5. Sidebar Link Delete
function deleteSidebarLink(linkId) {
    if (confirm("Sure, You Want to Delete it?")) {
        fetch(`http://127.0.0.1:${PORT_SIDEBAR}/delete_link/${linkId}`, { method: 'DELETE' })
            .then(res => res.json())
            .then(data => {
                if (data.status === 'success') {
                    location.reload();
                } else {
                    alert("Nahi hua delete: " + data.message);
                }
            }).catch(err => alert("Server error!"));
    }
}

// 6. Submenu Toggle (Optional if you have nested menus)
function toggleMenu(id) {
    let m = document.getElementById(id);
    if (!m) return;
    // Only close submenus that are not parents or children of the current one
    document.querySelectorAll('.submenu').forEach(s => { 
        if (s.id !== id && !s.contains(m) && !m.contains(s)) {
            s.style.display = 'none'; 
        }
    });
    m.style.display = (m.style.display === 'block') ? 'none' : 'block';
}