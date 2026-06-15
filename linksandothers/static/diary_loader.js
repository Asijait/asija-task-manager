/**
 * Injects the Daily Diary icon into the sidebar
 */
function initDiaryButton() {
    const sidebar = document.querySelector('.sidebar');
    if (sidebar) {
        // Try to find the existing tool row or create a new section
        let toolsRow = document.getElementById('sidebar-tools-row');
        
        if (!toolsRow) {
            const wrapper = document.createElement('div');
            wrapper.className = 'menu-item';
            toolsRow = document.createElement('div');
            toolsRow.id = 'sidebar-tools-row';
            toolsRow.style.display = 'flex';
            toolsRow.style.gap = '10px';
            toolsRow.style.padding = '5px 0';
            toolsRow.style.justifyContent = 'center';
            wrapper.appendChild(toolsRow);
            sidebar.appendChild(wrapper);
        }

        const diaryBtn = document.createElement('button');
        diaryBtn.className = 'menu-btn';
        diaryBtn.style.width = '50px';
        diaryBtn.style.background = '#1abc9c';
        diaryBtn.innerHTML = '📔';
        diaryBtn.title = 'Daily Work Diary';
        diaryBtn.onclick = () => {
            window.open('/diary', '_blank');
        };
        toolsRow.appendChild(diaryBtn);
    }
}

document.addEventListener('DOMContentLoaded', initDiaryButton);