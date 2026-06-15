document.addEventListener('DOMContentLoaded', function() {
    const dataEl = document.getElementById('dashboardData');
    if (!dataEl) return;

    const data = JSON.parse(dataEl.textContent || '{}');
    const palette = ['#1f618d', '#27ae60', '#d68910', '#8e44ad', '#c0392b', '#16a085', '#7f8c8d', '#2e86c1'];

    function money(value) {
        const amount = Math.round(Number(value) || 0);
        const sign = amount < 0 ? '-' : '';
        const text = String(Math.abs(amount));
        const lastThree = text.slice(-3);
        const rest = text.slice(0, -3);
        return `${sign}₹ ${rest ? `${rest.replace(/\B(?=(\d{2})+(?!\d))/g, ',')},${lastThree}` : lastThree}`;
    }

    function fitCanvas(canvas) {
        const ratio = window.devicePixelRatio || 1;
        const rect = canvas.getBoundingClientRect();
        canvas.width = Math.max(1, Math.floor(rect.width * ratio));
        canvas.height = Math.max(1, Math.floor((Number(canvas.getAttribute('height')) || 180) * ratio));
        const ctx = canvas.getContext('2d');
        ctx.setTransform(ratio, 0, 0, ratio, 0, 0);
        return { ctx, width: rect.width, height: Number(canvas.getAttribute('height')) || 180 };
    }

    function label(ctx, text, x, y, maxWidth) {
        const value = String(text || 'Unassigned');
        if (ctx.measureText(value).width <= maxWidth) {
            ctx.fillText(value, x, y);
            return;
        }
        let shortened = value;
        while (shortened.length > 3 && ctx.measureText(`${shortened}...`).width > maxWidth) {
            shortened = shortened.slice(0, -1);
        }
        ctx.fillText(`${shortened}...`, x, y);
    }

    function drawBarChart(canvasId, rows, options) {
        const canvas = document.getElementById(canvasId);
        if (!canvas) return;

        const items = (rows || []).filter(item => Number(item.total) > 0);
        canvas._chartHits = [];
        const { ctx, width, height } = fitCanvas(canvas);
        ctx.clearRect(0, 0, width, height);
        ctx.font = '12px Arial';
        ctx.fillStyle = '#607382';

        if (!items.length) {
            ctx.fillText('No data available', 12, 24);
            return;
        }

        const left = options && options.compact ? 8 : 92;
        const right = 82;
        const top = 12;
        const rowGap = 8;
        const barHeight = Math.max(12, Math.min(24, (height - top - rowGap * (items.length - 1)) / items.length));
        const max = Math.max(...items.map(item => Number(item.total) || 0));
        const barWidth = Math.max(20, width - left - right);

        items.forEach((item, index) => {
            const y = top + index * (barHeight + rowGap);
            const value = Number(item.total) || 0;
            const length = max ? (value / max) * barWidth : 0;
            ctx.fillStyle = '#607382';
            if (!(options && options.compact)) label(ctx, item.label, 8, y + barHeight - 5, left - 14);
            ctx.fillStyle = palette[index % palette.length];
            ctx.fillRect(left, y, length, barHeight);
            if (item.url) {
                canvas._chartHits.push({ x: 0, y: y - 3, width, height: barHeight + 6, url: item.url });
            }
            ctx.fillStyle = '#203040';
            ctx.font = '12px Arial';
            ctx.fillText(money(value), left + length + 8, y + barHeight - 5);
            if (options && options.compact) {
                ctx.fillStyle = '#203040';
                label(ctx, item.label, left + 6, y + barHeight - 5, Math.max(40, length - 12));
            }
        });
    }

    function drawDonut(canvasId, rows) {
        const canvas = document.getElementById(canvasId);
        if (!canvas) return;

        const items = (rows || []).filter(item => Number(item.total) > 0);
        const { ctx, width, height } = fitCanvas(canvas);
        ctx.clearRect(0, 0, width, height);

        if (!items.length) {
            ctx.fillStyle = '#607382';
            ctx.fillText('No data available', 12, 24);
            return;
        }

        const total = items.reduce((sum, item) => sum + Number(item.total || 0), 0);
        const cx = Math.min(width * 0.3, 120);
        const cy = height / 2;
        const radius = Math.min(height * 0.36, 68);
        let start = -Math.PI / 2;

        items.forEach((item, index) => {
            const angle = total ? (Number(item.total) / total) * Math.PI * 2 : 0;
            ctx.beginPath();
            ctx.moveTo(cx, cy);
            ctx.arc(cx, cy, radius, start, start + angle);
            ctx.closePath();
            ctx.fillStyle = palette[index % palette.length];
            ctx.fill();
            start += angle;
        });

        ctx.beginPath();
        ctx.arc(cx, cy, radius * 0.58, 0, Math.PI * 2);
        ctx.fillStyle = '#fff';
        ctx.fill();
        ctx.fillStyle = '#203040';
        ctx.font = '700 13px Arial';
        ctx.textAlign = 'center';
        ctx.fillText(money(total), cx, cy + 4);
        ctx.textAlign = 'left';

        const legendX = Math.min(width * 0.54, cx + radius + 35);
        items.slice(0, 6).forEach((item, index) => {
            const y = 22 + index * 22;
            ctx.fillStyle = palette[index % palette.length];
            ctx.fillRect(legendX, y - 10, 10, 10);
            ctx.fillStyle = '#203040';
            ctx.font = '12px Arial';
            label(ctx, `${item.label} (${Math.round((Number(item.total) / total) * 100)}%)`, legendX + 16, y, width - legendX - 24);
        });
    }

    function render() {
        drawBarChart('ageingChart', data.ageing || [], { compact: true });
        drawBarChart('followupChart', data.followup || []);
        drawDonut('categoryChart', data.category || []);
        drawBarChart('epChart', data.ep || []);
        drawBarChart('fyChart', data.fy || [], { compact: true });
    }

    render();
    window.addEventListener('resize', render);

    document.querySelectorAll('canvas').forEach(canvas => {
        canvas.addEventListener('click', event => {
            const rect = canvas.getBoundingClientRect();
            const x = event.clientX - rect.left;
            const y = event.clientY - rect.top;
            const hit = (canvas._chartHits || []).find(item =>
                x >= item.x && x <= item.x + item.width && y >= item.y && y <= item.y + item.height
            );
            if (hit) window.open(hit.url, '_blank', 'noopener');
        });

        canvas.addEventListener('mousemove', event => {
            const rect = canvas.getBoundingClientRect();
            const x = event.clientX - rect.left;
            const y = event.clientY - rect.top;
            const hit = (canvas._chartHits || []).some(item =>
                x >= item.x && x <= item.x + item.width && y >= item.y && y <= item.y + item.height
            );
            canvas.style.cursor = hit ? 'pointer' : '';
        });
    });
});
