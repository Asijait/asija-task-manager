// --- 1. CSS & HTML INJECTION (Fairy) ---
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
`;
document.head.appendChild(fairyStyles);

const fairyDiv = document.createElement('div');
fairyDiv.id = 'fairyNotify';
fairyDiv.className = 'fairy-container';
fairyDiv.innerHTML = `<div class="fairy-icon">🧚✨</div><div class="fairy-bubble" id="fairyText">DATA SAVED!</div>`;
document.body.appendChild(fairyDiv);

// --- 2. FAIRY ANIMATION LOGIC ---
function showFairy(msg = "DATA SAVED!") {
    const fairyNotify = document.getElementById('fairyNotify');
    const fairyText = document.getElementById('fairyText');
    fairyText.innerText = msg;
    fairyNotify.classList.add('fairy-show');
    setTimeout(() => {
        fairyNotify.classList.remove('fairy-show');
    }, 3500);
}

// --- 3. COMMON CALCULATIONS ---
function formatTime(s) {
    s = parseInt(s) || 0;
    let h = Math.floor(s / 3600);
    let m = Math.floor((s % 3600) / 60);
    let sec = s % 60;
    return `${h}h ${m}m ${sec}s`;
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
    // Ensure you have these IDs in HTML
    if(document.getElementById('totalTasks')) document.getElementById('totalTasks').innerText = c.total;
    if(document.getElementById('assignedTasks')) document.getElementById('assignedTasks').innerText = c.Assign;
    if(document.getElementById('pendingTasks')) document.getElementById('pendingTasks').innerText = c.WIP;
    if(document.getElementById('completedTasks')) document.getElementById('completedTasks').innerText = c.Completed;
    if(document.getElementById('closedTasks')) document.getElementById('closedTasks').innerText = c.Final;
}

// Page load par Summary update karein
window.addEventListener('DOMContentLoaded', updateSummary);