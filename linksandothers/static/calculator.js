let calcHistory = [];
let isResultDisplayed = false;
let activeKeyboardListener = null;

async function initCalculator() {
    try {
        // Load CSS
        const link = document.createElement('link');
        link.rel = 'stylesheet';
        link.href = '/static/calculator.css';
        document.head.appendChild(link);

        // Load HTML
        const response = await fetch('/static/calculator.html');
        const html = await response.text();
        document.body.insertAdjacentHTML('beforeend', html);
        setupCalculatorLogic();

        // Add button to Sidebar
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

            const calcBtn = document.createElement('button');
            calcBtn.className = 'menu-btn';
            calcBtn.style.width = '50px';
            calcBtn.style.background = '#34495e';
            calcBtn.innerHTML = '🧮';
            calcBtn.title = 'Mohd Arif - Calculator';
            calcBtn.onclick = () => document.getElementById('calculator-container').classList.toggle('active');
            toolsRow.appendChild(calcBtn);
        }
    } catch (e) {
        console.error("Calculator Init Error:", e);
    }
}

window.closeCalculator = () => document.getElementById('calculator-container').classList.remove('active');

function setupCalculatorLogic() {
    const buttons = document.querySelectorAll("#calculator-container .btn");
    
    buttons.forEach(btn => {
        btn.addEventListener("click", () => handleCalcInput(btn.textContent));
    });

    // Keyboard support
    if (activeKeyboardListener) {
        document.removeEventListener("keydown", activeKeyboardListener);
    }
    activeKeyboardListener = (event) => {
        const container = document.getElementById('calculator-container');
        if (!container || !container.classList.contains('active')) return;

        const key = event.key;
        if (!isNaN(key) || ["+", "-", "*", "/", "."].includes(key)) {
            handleCalcInput(key);
        } else if (key === "Enter") {
            handleCalcInput("=");
        } else if (key === "Backspace") {
            handleCalcInput("DEL");
        } else if (key === "Escape") {
            closeCalculator();
        } else if (key.toLowerCase() === "r") {
            handleCalcInput("RESET");
        }
    };
    document.addEventListener("keydown", activeKeyboardListener);
}

window.handleCalcInput = (value) => {
    const display = document.getElementById("calc-display");
    if (value === "DEL") {
        display.textContent = display.textContent.slice(0, -1) || "0";
        isResultDisplayed = false;
    } else if (value === "RESET") {
        display.textContent = "0";
        isResultDisplayed = false;
    } else if (value === "=") {
        try {
            const expression = display.textContent;
            const result = new Function(`"use strict"; return (${expression})`)();
            display.textContent = result;
            updateCalcHistory(expression, result);
            isResultDisplayed = true;
        } catch {
            display.textContent = "Error";
            isResultDisplayed = true;
        }
    } else {
        const isOperator = ["+", "-", "*", "/"].includes(value);
        if (isResultDisplayed) {
            if (!isOperator) {
                display.textContent = (value === "." ? "0" : "");
            } else if (display.textContent === "Error") {
                display.textContent = "0";
            }
            isResultDisplayed = false;
        }
        if (display.textContent === "0" && !isOperator && value !== ".") {
            display.textContent = value;
        } else {
            display.textContent += value;
        }
    }
};

function updateCalcHistory(expression, result) {
    const inlineHistory = document.getElementById("calc-history-inline");
    calcHistory.unshift(`${expression} = ${result}`);
    if (calcHistory.length > 2) calcHistory.pop(); 
    inlineHistory.innerHTML = calcHistory.map(item => `<div>${item}</div>`).join('');
}

document.addEventListener('DOMContentLoaded', initCalculator);