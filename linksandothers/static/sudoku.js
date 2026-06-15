let currentSolution = [];

async function initSudoku() {
    try {
        // Load CSS
        const link = document.createElement('link');
        link.rel = 'stylesheet';
        link.href = '/static/sudoku.css';
        document.head.appendChild(link);

        // Load HTML
        const response = await fetch('/static/sudoku.html');
        const html = await response.text();
        document.body.insertAdjacentHTML('beforeend', html);

        const sidebar = document.querySelector('.sidebar');
        if (sidebar) {
            let toolsRow = document.getElementById('sidebar-tools-row');
            if (!toolsRow) {
                const menuItem = document.createElement('div');
                menuItem.className = 'menu-item';
                toolsRow = document.createElement('div');
                toolsRow.id = 'sidebar-tools-row';
                toolsRow.style.display = 'flex';
                toolsRow.style.gap = '10px';
                toolsRow.style.padding = '5px 15px';
                menuItem.appendChild(toolsRow);
                sidebar.appendChild(menuItem);
            }

            const gameBtn = document.createElement('button');
            gameBtn.className = 'menu-btn';
            gameBtn.style.width = '50px';
            gameBtn.style.background = '#34495e';
            gameBtn.innerHTML = '🧩';
            gameBtn.title = 'Sudoku Game';
            gameBtn.onclick = () => {
                document.getElementById('sudoku-container').classList.toggle('active');
                if (document.getElementById('sudoku-container').classList.contains('active')) generateNewGame();
            };
            toolsRow.appendChild(gameBtn);
        }
    } catch (e) { 
        console.error("Sudoku Init Error:", e); 
    }
}

window.closeSudoku = () => document.getElementById('sudoku-container').classList.remove('active');

function generateNewGame() {
    const grid = document.getElementById('sudoku-grid');
    const msg = document.getElementById('sudoku-message');
    grid.innerHTML = '';
    msg.innerText = '';

    // Base valid board to shuffle from
    const baseBoard = [
        [5,3,4,6,7,8,9,1,2],[6,7,2,1,9,5,3,4,8],[1,9,8,3,4,2,5,6,7],
        [8,5,9,7,6,1,4,2,3],[4,2,6,8,5,3,7,9,1],[7,1,3,9,2,4,8,5,6],
        [9,6,1,5,3,7,2,8,4],[2,8,7,4,1,9,6,3,5],[3,4,5,2,8,6,1,7,9]
    ];

    // Simple shuffle: map numbers to new ones
    const nums = [1,2,3,4,5,6,7,8,9].sort(() => Math.random() - 0.5);
    currentSolution = baseBoard.map(row => row.map(cell => nums[cell - 1]));

    for(let r=0; r<9; r++) {
        for(let c=0; c<9; c++) {
            const input = document.createElement('input');
            input.type = 'text';
            input.inputMode = 'numeric';
            input.dataset.row = r;
            input.dataset.col = c;
            
            // Show ~35 numbers
            if(Math.random() > 0.55) {
                input.value = currentSolution[r][c];
                input.readOnly = true;
                input.classList.add('prefilled');
            }

            // Prevent non-numeric input
            input.oninput = (e) => {
                e.target.value = e.target.value.replace(/[^1-9]/g, '').slice(0,1);
            };
            
            grid.appendChild(input);
        }
    }
}

function checkSudoku() {
    const inputs = document.querySelectorAll('#sudoku-grid input');
    const msg = document.getElementById('sudoku-message');
    let isComplete = true;
    let isCorrect = true;

    inputs.forEach(input => {
        const r = input.dataset.row;
        const c = input.dataset.col;
        const val = parseInt(input.value);

        if (!val) {
            isComplete = false;
            input.style.background = '#fff';
        } else if (val !== currentSolution[r][c]) {
            isCorrect = false;
            input.style.background = '#ffd7d7';
        } else {
            input.style.background = input.classList.contains('prefilled') ? '#f1f1f1' : '#d7ffd7';
        }
    });

    if (!isComplete) {
        msg.innerText = "⚠️ Fill all the boxes!";
        msg.style.color = "#e67e22";
    } else if (!isCorrect) {
        msg.innerText = "❌ Something is wrong. Keep trying!";
        msg.style.color = "#e74c3c";
    } else {
        msg.innerText = "🎉 Perfect! You solved it!";
        msg.style.color = "#27ae60";
    }
}

document.addEventListener('DOMContentLoaded', initSudoku);