// Check karein ki kya user links-and-others page par hai
if (window.location.pathname.includes('/links-and-others')) {
    document.body.classList.add('links-only-page');

    // Create Football Field Elements
    document.body.innerHTML += `
        <div id="score-board">YOU: 0 | CPU: 0</div>
        <div class="goal-post goal-left"></div>
        <div class="goal-post goal-right"></div>
        <div id="player" class="player-striker">ME</div>
        <div id="cpu" class="cpu-striker">CPU</div>
        <div id="ball" class="football"></div>
    `;

    const ballEl = document.getElementById('ball');
    const playerEl = document.getElementById('player');
    const cpuEl = document.getElementById('cpu');
    const scoreEl = document.getElementById('score-board');

    let ball = { x: window.innerWidth/2, y: window.innerHeight/2, dx: 5, dy: 5 };
    let player = { y: window.innerHeight/2 };
    let cpu = { y: window.innerHeight/2 };
    let scores = { player: 0, cpu: 0 };

    const resetBall = () => {
        ball.x = (window.innerWidth + 300) / 2;
        ball.y = window.innerHeight / 2;
        ball.dx = Math.random() > 0.5 ? 5 : -5;
        ball.dy = (Math.random() - 0.5) * 10;
    };

    // Mouse Control for Player
    window.addEventListener('mousemove', (e) => {
        player.y = e.clientY - 25;
        playerEl.style.top = player.y + 'px';
        playerEl.style.left = '330px';
    });

    function gameLoop() {
        // Ball Physics
        ball.x += ball.dx;
        ball.y += ball.dy;

        // Wall Bounce (Top/Bottom)
        if (ball.y <= 0 || ball.y >= window.innerHeight - 40) ball.dy *= -1;

        // CPU AI (Simple follow)
        let cpuTarget = ball.y - 25;
        cpu.y += (cpuTarget - cpu.y) * 0.1;
        cpuEl.style.top = cpu.y + 'px';
        cpuEl.style.right = '40px';

        // Player Collision
        if (ball.x <= 380 && ball.x >= 330 && ball.y >= player.y - 20 && ball.y <= player.y + 50) {
            ball.dx = Math.abs(ball.dx) + 0.5; // Speed up
            ball.dy = (ball.y - (player.y + 25)) * 0.3;
        }

        // CPU Collision
        if (ball.x >= window.innerWidth - 90 && ball.x <= window.innerWidth - 40 && ball.y >= cpu.y - 20 && ball.y <= cpu.y + 50) {
            ball.dx = -Math.abs(ball.dx) - 0.5;
            ball.dy = (ball.y - (cpu.y + 25)) * 0.3;
        }

        // Goals
        if (ball.x < 310) {
            if (ball.y > window.innerHeight/2 - 100 && ball.y < window.innerHeight/2 + 100) {
                scores.cpu++;
                updateScore();
                resetBall();
            } else {
                ball.dx *= -1;
            }
        }
        if (ball.x > window.innerWidth - 20) {
            if (ball.y > window.innerHeight/2 - 100 && ball.y < window.innerHeight/2 + 100) {
                scores.player++;
                makeItRainbow(); // Goal celebration!
                updateScore();
                resetBall();
            } else {
                ball.dx *= -1;
            }
        }

        ballEl.style.left = ball.x + 'px';
        ballEl.style.top = ball.y + 'px';

        requestAnimationFrame(gameLoop);
    }

    function updateScore() {
        scoreEl.innerText = `YOU: ${scores.player} | CPU: ${scores.cpu}`;
    }

    resetBall();
    gameLoop();
}

const statusOptions = ["Assign", "WIP", "Discussion Pending", "Close", "Completed", "Final & Approved"];
const PORT = "5001";
let activeTimers = {};

// --- 1. CSS & HTML INJECTION (Pari & Animations) ---
const fairyStyles = document.createElement('style');
fairyStyles.innerHTML = `
    .fairy-container {
        position: fixed; bottom: -150px; right: 30px;
        display: flex; flex-direction: column; align-items: center;
        z-index: 10000; transition: all 0.8s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        pointer-events: none;
    }
    .fairy-show { bottom: 80px !important; }
    .fairy-icon { font-size: 60px; filter: drop-shadow(0 0 10px gold); animation: hoverFairy 2s ease-in-out infinite; }
    .fairy-bubble {
        background: #fff; padding: 10px 20px; border-radius: 25px;
        border: 2px solid #1abc9c; font-weight: bold; color: #2c3e50;
        box-shadow: 0 5px 15px rgba(0,0,0,0.2); margin-top: 5px; font-size: 14px;
        position: relative;
    }
    .fairy-bubble::after {
        content: ''; position: absolute; top: -10px; left: 50%;
        border-width: 0 10px 10px 10px; border-style: solid;
        border-color: transparent transparent #1abc9c transparent;
        transform: translateX(-50%);
    }
    @keyframes hoverFairy { 0%, 100% { transform: translateY(0) rotate(-5deg); } 50% { transform: translateY(-20px) rotate(5deg); } }
    .vertical-controls {
        display: flex !important;
        flex-direction: row !important; 
        align-items: center !important;
        gap: 15px !important;
        padding: 10px 20px !important;
        background: #fff !important;
        border: 2px solid #1abc9c !important;
        border-radius: 12px !important;
        box-shadow: 0 4px 15px rgba(0,0,0,0.1) !important;

        /* YE LINES WRAPPING ROKENGI */
        min-width: 600px !important; /* Box ko itna bada rakhega ki sab fit ho jaye */
        white-space: nowrap !important; /* Text ya timer ko niche nahi girne dega */
    }

    .timer-display-wrapper {
        min-width: 120px !important; /* Timer ke liye fix jagah */
        text-align: center !important;
        font-weight: bold !important;
        color: #1abc9c !important;
    }
    
    /* Edit, Save aur Del buttons ke beech gap ke liye */
    .action-controls {
        display: flex !important;
        gap: 8px !important;
    }
`;
document.head.appendChild(fairyStyles);

const fairyDiv = document.createElement('div');
fairyDiv.id = 'fairyNotify';
fairyDiv.className = 'fairy-container';
fairyDiv.innerHTML = `<div class="fairy-icon">🧚✨</div><div class="fairy-bubble">DATA SAVED!</div>`;
document.body.appendChild(fairyDiv);

// --- 2. ANIMATIONS (Stars & Fairy) ---
function makeItRainbow() {
    if (typeof confetti === 'function') {
        confetti({
            particleCount: 100,
            spread: 70,
            origin: { y: 0.6 },
            shapes: ['star'],
            colors: ['#d4af37', '#1abc9c', '#e67e22']
        });
    }
}

function showFairy() {
    const fairy = document.getElementById('fairyNotify');
    fairy.classList.add('fairy-show');
    setTimeout(() => { fairy.classList.remove('fairy-show'); }, 3500);
}

// --- 5. CORE DASHBOARD LOGIC ---
function loadTasks() {
    fetch(`http://127.0.0.1:${PORT}/get_tasks`)
        .then(res => res.json())
        .then(data => {
            if (data && data.length > 0) {
                // Reverse the array for prepend logic to maintain DESC order correctly
                const reversedData = [...data].reverse();
                reversedData.forEach(item => addRow(false, item.inflowdate, item.work_name, item.target_date, item.status, item.allocated_to, item.total_seconds));
                
                reIndexRows();
                updateSummary();
                filterTasks();
            }
        });
}

window.addEventListener('load', loadTasks);


function addRow(isNew = false, eDate = '', wName = '', tDate = '', status = 'Assign', allocatedTo = '', totalSeconds = 0) {
    const tbody = document.getElementById("tableBody");
    const row = document.createElement('tr');

    if (!isNew) row.classList.add('locked');
    row.onclick = function () { toggleRowButtons(this); };

    row.innerHTML = `
    <td class="row-index"></td>
    <td>
        <input type="date" value="${eDate || new Date().toISOString().split('T')[0]}" readonly>
    </td>
    <td>
        <input type="text" class="work-input" value="${allocatedTo || ''}" 
               placeholder="Person (Optional)">
    </td>
    <td class="work-cell">
        <textarea class="work-input" oninput="autoHeight(this)" 
                  placeholder="What is the task?" required>${wName}</textarea>
    </td>
    <td>
        <input type="date" value="${tDate || new Date().toISOString().split('T')[0]}" required>
    </td>
    <td>
        <select onchange="handleStatusChange(this)">
            ${statusOptions.map(opt => `<option value="${opt}" ${opt === status ? 'selected' : ''}>${opt}</option>`).join('')}
        </select>
    </td>
    <td>
        <div class="vertical-controls">
            <div class="timer-controls">
                <button class="start-btn" onclick="event.stopPropagation(); startTimer(this)">START</button>
                <button class="stop-btn" onclick="event.stopPropagation(); stopTimer(this)" disabled>END</button>
            </div>
            <div class="timer-display-wrapper">
                <span class="timer-display">${formatTime(totalSeconds)}</span>
            </div>
            <div class="action-controls">
                <button onclick="event.stopPropagation(); toggleEdit(this)" class="edit-btn">EDIT</button>
                <button onclick="event.stopPropagation(); togglesave(this)" class="save-btn">Save</button>
                <button onclick="event.stopPropagation(); deleteRow(this)" class="del-btn">DEL</button>
            </div>
            <input type="hidden" class="total-seconds" value="${totalSeconds}">
        </div>
    </td>`;

    // Naya task hamesha upar (Top) aayega
    tbody.prepend(row);

    autoHeight(row.querySelector('textarea'));
    if(isNew) reIndexRows();
}
function validateAndSave() {
    const rows = document.querySelectorAll("#tableBody tr");
    let isValid = true;
    let errorMessage = "";

    const data = Array.from(rows).map((row, index) => {
        const personInput = row.cells[2].querySelector('input');
        const workArea = row.cells[3].querySelector('textarea');
        
        const person = personInput.value.trim();
        const workName = workArea.value.trim();

        // SMART VALIDATION: Sirf un rows ko check karo jo locked NAHI hain
        if (!row.classList.contains('locked')) {
            if (person === "" || workName === "") {
                isValid = false;
                row.style.outline = "2px solid #e74c3c"; // Error highlight
                errorMessage = `Bhai, Row #${index + 1} mein Person aur Work Name dono mandatory hain!`;
            } else {
                row.style.outline = "none";
            }
        }

        return {
            eDate: row.cells[1].querySelector('input').value,
            allocatedTo: person,
            wName: workName,
            tDate: row.cells[4].querySelector('input').value,
            status: row.cells[5].querySelector('select').value,
            totalSeconds: row.querySelector('.total-seconds').value
        };
    });

    // Agar validation fail hua toh alert dikhao aur ruk jao
    if (!isValid) {
        alert(errorMessage);
        return;
    }

    // Sab sahi hai toh server par save karo
    fetch(`http://127.0.0.1:${PORT}/save_tasks`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    }).then(res => {
        if (res.ok) {
            // Saari rows ko wapas lock kar do
            document.querySelectorAll("#tableBody tr").forEach(r => {
                r.classList.add('locked');
                const eb = r.querySelector('.edit-btn');
                if (eb) eb.innerText = "EDIT";
                r.style.outline = "none";
            });

            showFairy();      // Success animation
            updateSummary();    // Stats update

            // UI Buttons ko normal state mein lao
            document.getElementById('saveTrigger').style.display = 'none';
            document.getElementById('addBtn').style.display = 'block';
            document.getElementById('addBtn').disabled = false;
            document.getElementById('cancelMasterBtn').style.display = 'none';
        } else {
            alert("Server error: Data save nahi ho paya!");
        }
    }).catch(err => {
        console.error("Save error:", err);
        alert("Network error: Server se connect nahi ho raha!");
    });
}

function exportToExcel() {
    const tableRows = document.querySelectorAll("#tableBody tr");
    if (tableRows.length === 0) {
        alert("Bhai, export karne ke liye koi data hi nahi hai!");
        return;
    }

    // Data collect karna Excel format ke liye
    const data = Array.from(tableRows).map((row, i) => {
        // Sirf wahi rows export karein jo filter mein dikh rahi hain (Optional)
        if (row.style.display === "none") return null;

        return {
            "Sl No": i + 1,
            "Inflow Date": row.cells[1].querySelector('input').value,
            "Person Name": row.cells[2].querySelector('input').value, // Naya column
            "Work Name": row.cells[3].querySelector('textarea').value,
            "Target Date": row.cells[4].querySelector('input').value,
            "Status": row.cells[5].querySelector('select').value,
            "Total Time": row.querySelector('.timer-display').innerText
        };
    }).filter(item => item !== null); // Hidden rows ko remove karna

    // Excel file generate karna
    const ws = XLSX.utils.json_to_sheet(data);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "DailyWorkReport");

    // File download trigger karna
    XLSX.writeFile(wb, `MAS_Report_${new Date().toLocaleDateString()}.xlsx`);
}



// --- IS FUNCTION KO BHI FILE MEIN KAHIN BHI DAAL DEIN ---
function toggleRowButtons(clickedRow) {
    // 1. Pehle check karo ki kya ye row pehle se hi active hai
    const alreadyActive = clickedRow.classList.contains('active-row');

    // 2. Sabhi rows se 'active-row' class hata do (taaki ek baar mein ek hi dikhe)
    document.querySelectorAll('#tableBody tr').forEach(row => {
        row.classList.remove('active-row');
    });

    // 3. Agar woh pehle se active nahi thi, toh ab active class laga do
    if (!alreadyActive) {
        clickedRow.classList.add('active-row');
    }
}



// Supporting Functions
function formatTime(s) {
    s = parseInt(s) || 0;
    return `${Math.floor(s / 3600)}h ${Math.floor((s % 3600) / 60)}m ${s % 60}s`;
}

function startTimer(btn) {
    const row = btn.closest('tr');
    btn.disabled = true; btn.innerText = "● LIVE";
    row.querySelector('.stop-btn').disabled = false;
    let hidden = row.querySelector('.total-seconds');
    activeTimers[row.rowIndex] = setInterval(() => {
        let s = parseInt(hidden.value) + 1;
        hidden.value = s;
        row.querySelector('.timer-display').innerText = formatTime(s);
    }, 1000);
}

function stopTimer(btn) {
    const row = btn.closest('tr');
    clearInterval(activeTimers[row.rowIndex]);
    btn.disabled = true; row.querySelector('.start-btn').disabled = false;
    row.querySelector('.start-btn').innerText = "START";
    // document.getElementById('saveTrigger').style.display = 'block';
    validateAndSave();
    console.log("Timer stopped and data auto-saved!");
}

function toggleEdit(btn) {
    const r = btn.closest('tr'); r.classList.toggle('locked');
    btn.innerText = r.classList.contains('locked') ? "EDIT" : "LOCK";
    if (!r.classList.contains('locked')) document.getElementById('saveTrigger').style.display = 'block';
}

function autoHeight(el) { el.style.height = "1px"; el.style.height = el.scrollHeight + "px"; }
function reIndexRows() { document.querySelectorAll("#tableBody tr").forEach((r, i) => r.querySelector('.row-index').innerText = i + 1); }
function addNewRow() { addRow(true); document.getElementById('addBtn').disabled = true; document.getElementById('saveTrigger').style.display = 'block'; }
function deleteRow(btn) { if (confirm("Delete?")) { btn.closest('tr').remove(); validateAndSave(); } }
function handleStatusChange(s) { updateSummary(); document.getElementById('saveTrigger').style.display = 'block'; }

function toggleFilterDropdown() {
    let m = document.getElementById('filterMenu');
    m.style.display = (m.style.display === 'block') ? 'none' : 'block';
}

function updateSummary() {
    let c = { total: 0, Assign: 0, WIP: 0, Completed: 0, Final: 0 };
    document.querySelectorAll("#tableBody tr").forEach(r => {
        let sel = r.querySelector('select');
        if (!sel) return;
        c.total++;
        let s = sel.value;
        if (s === 'Assign') c.Assign++;
        else if (s === 'WIP' || s === 'Discussion Pending') c.WIP++;
        else if (s === 'Completed') c.Completed++;
        else if (s === 'Final & Approved' || s === 'Close') c.Final++;
    });
    if(document.getElementById('totalTasks')) document.getElementById('totalTasks').innerText = c.total;
    if(document.getElementById('assignedTasks')) document.getElementById('assignedTasks').innerText = c.Assign;
    if(document.getElementById('pendingTasks')) document.getElementById('pendingTasks').innerText = c.WIP;
    if(document.getElementById('completedTasks')) document.getElementById('completedTasks').innerText = c.Completed;
    if(document.getElementById('closedTasks')) document.getElementById('closedTasks').innerText = c.Final;
}

function filterTasks() {
    let searchVal = document.getElementById('taskSearch').value.toLowerCase();
    let selected = Array.from(document.querySelectorAll('.status-chk:checked')).map(cb => cb.value);
    document.querySelectorAll("#tableBody tr").forEach(row => {
        let work = row.cells[3].querySelector('textarea').value.toLowerCase();
        let name = row.cells[2].querySelector('input').value.toLowerCase();
        let status = row.cells[5].querySelector('select').value;
        row.style.display = ((work.includes(searchVal) || name.includes(searchVal)) && (selected.length === 0 || selected.includes(status))) ? "" : "none";
    });
}

function toggleAllFilters(master) {
    document.querySelectorAll('.status-chk').forEach(cb => cb.checked = master.checked);
    filterTasks();
}

function togglesave(btn) {
    const row = btn.closest('tr');
    
    // 1. Pehle row ko lock kar do (taaki validateAndSave usey valid maane)
    row.classList.add('locked');
    
    // 2. Edit button ka text wapas "EDIT" kar do
    const editBtn = row.querySelector('.edit-btn');
    if (editBtn) editBtn.innerText = "EDIT";

    // 3. Ab aapka purana master function call kar lo
    // Ye function ab saara data uthayega aur server pe bhej dega
    validateAndSave();

    // 4. UI controls ko normal kar do
    document.getElementById('addBtn').style.display = 'block';
    document.getElementById('addBtn').disabled = false;
    document.getElementById('cancelMasterBtn').style.display = 'none';
}
