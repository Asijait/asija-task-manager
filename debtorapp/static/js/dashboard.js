// document.addEventListener('DOMContentLoaded', function() {
//     const dataEl = document.getElementById('dashboardData');
//     if (!dataEl) return;

//     const data = JSON.parse(dataEl.textContent || '{}');
//     const palette = ['#1f618d', '#27ae60', '#d68910', '#8e44ad', '#c0392b', '#16a085', '#7f8c8d', '#2e86c1'];

//     function money(value) {
//         const amount = Math.round(Number(value) || 0);
//         const sign = amount < 0 ? '-' : '';
//         const text = String(Math.abs(amount));
//         const lastThree = text.slice(-3);
//         const rest = text.slice(0, -3);
//         return `${sign}₹ ${rest ? `${rest.replace(/\B(?=(\d{2})+(?!\d))/g, ',')},${lastThree}` : lastThree}`;
//     }

//     function fitCanvas(canvas) {
//         const ratio = window.devicePixelRatio || 1;
//         const rect = canvas.getBoundingClientRect();
//         canvas.width = Math.max(1, Math.floor(rect.width * ratio));
//         canvas.height = Math.max(1, Math.floor((Number(canvas.getAttribute('height')) || 180) * ratio));
//         const ctx = canvas.getContext('2d');
//         ctx.setTransform(ratio, 0, 0, ratio, 0, 0);
//         return { ctx, width: rect.width, height: Number(canvas.getAttribute('height')) || 180 };
//     }

//     function label(ctx, text, x, y, maxWidth) {
//         const value = String(text || 'Unassigned');
//         if (ctx.measureText(value).width <= maxWidth) {
//             ctx.fillText(value, x, y);
//             return;
//         }
//         let shortened = value;
//         while (shortened.length > 3 && ctx.measureText(`${shortened}...`).width > maxWidth) {
//             shortened = shortened.slice(0, -1);
//         }
//         ctx.fillText(`${shortened}...`, x, y);
//     }

//     function drawBarChart(canvasId, rows, options) {
//         const canvas = document.getElementById(canvasId);
//         if (!canvas) return;

//         const items = (rows || []).filter(item => Number(item.total) > 0);
//         canvas._chartHits = [];
//         const { ctx, width, height } = fitCanvas(canvas);
//         ctx.clearRect(0, 0, width, height);
//         ctx.font = '12px Arial';
//         ctx.fillStyle = '#607382';

//         if (!items.length) {
//             ctx.fillText('No data available', 12, 24);
//             return;
//         }

//         const left = options && options.left
//             ? Number(options.left)
//             : (options && options.compact ? 8 : 92);
//         const right = 82;
//         const top = 12;
//         const rowGap = 8;
//         const barHeight = Math.max(12, Math.min(24, (height - top - rowGap * (items.length - 1)) / items.length));
//         const max = Math.max(...items.map(item => Number(item.total) || 0));
//         const barWidth = Math.max(20, width - left - right);

//         items.forEach((item, index) => {
//             const y = top + index * (barHeight + rowGap);
//             const value = Number(item.total) || 0;
//             const length = max ? (value / max) * barWidth : 0;
//             ctx.fillStyle = '#607382';
//             if (!(options && options.compact)) label(ctx, item.label, 8, y + barHeight - 5, left - 14);
//             ctx.fillStyle = palette[index % palette.length];
//             ctx.fillRect(left, y, length, barHeight);
//             if (item.url) {
//                 canvas._chartHits.push({ x: 0, y: y - 3, width, height: barHeight + 6, url: item.url });
//             }
//             ctx.fillStyle = '#203040';
//             ctx.font = '12px Arial';
//             ctx.fillText(money(value), left + length + 8, y + barHeight - 5);
//             if (options && options.compact) {
//                 ctx.fillStyle = '#203040';
//                 label(ctx, item.label, left + 6, y + barHeight - 5, Math.max(40, length - 12));
//             }
//         });
//     }

//     function drawDonut(canvasId, rows) {
//         const canvas = document.getElementById(canvasId);
//         if (!canvas) return;

//         const items = (rows || []).filter(item => Number(item.total) > 0);
//         const { ctx, width, height } = fitCanvas(canvas);
//         ctx.clearRect(0, 0, width, height);

//         if (!items.length) {
//             ctx.fillStyle = '#607382';
//             ctx.fillText('No data available', 12, 24);
//             return;
//         }

//         const total = items.reduce((sum, item) => sum + Number(item.total || 0), 0);
//         const cx = Math.min(width * 0.3, 120);
//         const cy = height / 2;
//         const radius = Math.min(height * 0.36, 68);
//         let start = -Math.PI / 2;

//         items.forEach((item, index) => {
//             const angle = total ? (Number(item.total) / total) * Math.PI * 2 : 0;
//             ctx.beginPath();
//             ctx.moveTo(cx, cy);
//             ctx.arc(cx, cy, radius, start, start + angle);
//             ctx.closePath();
//             ctx.fillStyle = palette[index % palette.length];
//             ctx.fill();
//             start += angle;
//         });

//         ctx.beginPath();
//         ctx.arc(cx, cy, radius * 0.58, 0, Math.PI * 2);
//         ctx.fillStyle = '#fff';
//         ctx.fill();
//         ctx.fillStyle = '#203040';
//         ctx.font = '700 13px Arial';
//         ctx.textAlign = 'center';
//         ctx.fillText(money(total), cx, cy + 4);
//         ctx.textAlign = 'left';

//         const legendX = Math.min(width * 0.54, cx + radius + 35);
//         items.slice(0, 6).forEach((item, index) => {
//             const y = 22 + index * 22;
//             ctx.fillStyle = palette[index % palette.length];
//             ctx.fillRect(legendX, y - 10, 10, 10);
//             ctx.fillStyle = '#203040';
//             ctx.font = '12px Arial';
//             label(ctx, `${item.label} (${Math.round((Number(item.total) / total) * 100)}%)`, legendX + 16, y, width - legendX - 24);
//         });
//     }

//     function render() {
//         drawBarChart('ageingChart', data.ageing || [], { compact: true });
//         drawBarChart('followupChart', data.followup || []);
//         drawDonut('categoryChart', data.category || []);
//         drawBarChart('epChart', data.ep || []);
//         drawBarChart('fyChart', data.fy || [], { left: 150 });
//     }

//     render();
//     window.addEventListener('resize', render);

//     document.querySelectorAll('canvas').forEach(canvas => {
//         canvas.addEventListener('click', event => {
//             const rect = canvas.getBoundingClientRect();
//             const x = event.clientX - rect.left;
//             const y = event.clientY - rect.top;
//             const hit = (canvas._chartHits || []).find(item =>
//                 x >= item.x && x <= item.x + item.width && y >= item.y && y <= item.y + item.height
//             );
//             if (hit) window.open(hit.url, '_blank', 'noopener');
//         });

//         canvas.addEventListener('mousemove', event => {
//             const rect = canvas.getBoundingClientRect();
//             const x = event.clientX - rect.left;
//             const y = event.clientY - rect.top;
//             const hit = (canvas._chartHits || []).some(item =>
//                 x >= item.x && x <= item.x + item.width && y >= item.y && y <= item.y + item.height
//             );
//             canvas.style.cursor = hit ? 'pointer' : '';
//         });
//     });
// });
document.addEventListener('DOMContentLoaded', function () {
    const dataEl = document.getElementById('dashboardData');

    if (!dataEl) {
        return;
    }

    let data = {};

    try {
        data = JSON.parse(
            dataEl.textContent || '{}'
        );
    } catch (error) {
        console.error(
            'Unable to parse dashboard data:',
            error
        );
        return;
    }

    const palette = [
        '#1f618d',
        '#27ae60',
        '#d68910',
        '#8e44ad',
        '#c0392b',
        '#16a085',
        '#7f8c8d',
        '#2e86c1'
    ];

    // ==========================================================
    // HELPERS
    // ==========================================================

    function money(value) {
        const amount = Math.round(
            Number(value) || 0
        );

        const sign =
            amount < 0
                ? '-'
                : '';

        const text = String(
            Math.abs(amount)
        );

        const lastThree =
            text.slice(-3);

        const rest =
            text.slice(0, -3);

        return (
            `${sign}₹ ${rest
                ? `${rest.replace(
                    /\B(?=(\d{2})+(?!\d))/g,
                    ','
                )},${lastThree}`
                : lastThree
            }`
        );
    }

    function fitCanvas(canvas) {
        const ratio =
            window.devicePixelRatio || 1;

        const rect =
            canvas.getBoundingClientRect();

        const height =
            Number(
                canvas.getAttribute('height')
            ) || 180;

        canvas.width =
            Math.max(
                1,
                Math.floor(
                    rect.width * ratio
                )
            );

        canvas.height =
            Math.max(
                1,
                Math.floor(
                    height * ratio
                )
            );

        const ctx =
            canvas.getContext('2d');

        ctx.setTransform(
            ratio,
            0,
            0,
            ratio,
            0,
            0
        );

        return {
            ctx,
            width: rect.width,
            height
        };
    }

    function label(
        ctx,
        text,
        x,
        y,
        maxWidth
    ) {
        const value =
            String(
                text || 'Unassigned'
            );

        if (
            ctx.measureText(value).width
            <= maxWidth
        ) {
            ctx.fillText(
                value,
                x,
                y
            );

            return;
        }

        let shortened =
            value;

        while (
            shortened.length > 3
            &&
            ctx.measureText(
                `${shortened}...`
            ).width > maxWidth
        ) {
            shortened =
                shortened.slice(0, -1);
        }

        ctx.fillText(
            `${shortened}...`,
            x,
            y
        );
    }

    // ==========================================================
    // DETAIL DIALOG
    // ==========================================================

    const dialog =
        document.getElementById(
            'dashboardDetailDialog'
        );

    const dialogTitle =
        document.getElementById(
            'dashboardDetailTitle'
        );

    const dialogSubtitle =
        document.getElementById(
            'dashboardDetailSubtitle'
        );

    const dialogCount =
        document.getElementById(
            'dashboardDetailCount'
        );

    const dialogTotal =
        document.getElementById(
            'dashboardDetailTotal'
        );

    const dialogStatus =
        document.getElementById(
            'dashboardDetailStatus'
        );

    const dialogBody =
        document.getElementById(
            'dashboardDetailBody'
        );

    const dialogClose =
        document.getElementById(
            'dashboardDetailClose'
        );

    function escapeHtml(value) {
        return String(
            value ?? ''
        )
            .replaceAll('&', '&amp;')
            .replaceAll('<', '&lt;')
            .replaceAll('>', '&gt;')
            .replaceAll('"', '&quot;')
            .replaceAll("'", '&#039;');
    }

    function openDialog() {
        if (!dialog) {
            console.error(
                'dashboardDetailDialog not found.'
            );
            return;
        }

        dialog.classList.add(
            'is-open'
        );

        dialog.setAttribute(
            'aria-hidden',
            'false'
        );

        document.body.classList.add(
            'dashboard-dialog-open'
        );
    }

    function closeDialog() {
        if (!dialog) {
            return;
        }

        dialog.classList.remove(
            'is-open'
        );

        dialog.setAttribute(
            'aria-hidden',
            'true'
        );

        document.body.classList.remove(
            'dashboard-dialog-open'
        );
    }

    function renderDetailRows(rows) {

        if (!rows || !rows.length) {

            dialogBody.innerHTML = `
                <tr>
                    <td
                        colspan="11"
                        class="dashboard-detail-empty"
                    >
                        No records found.
                    </td>
                </tr>
            `;

            return;
        }

        dialogBody.innerHTML =
            rows.map(row => `
                <tr>
                    <td>
                        ${escapeHtml(
                row.bill_date
            )}
                    </td>

                    <td>
                        ${escapeHtml(
                row.firm
            )}
                    </td>

                    <td>
                        ${escapeHtml(
                row.ref_no
            )}
                    </td>

                    <td>
                        ${escapeHtml(
                row.party_name
            )}
                    </td>

                    <td class="dashboard-detail-amount">
                        ₹ ${escapeHtml(
                row.amount_display
            )}
                    </td>

                    <td>
                        ${escapeHtml(
                row.due_date
            )}
                    </td>

                    <td>
                        ${escapeHtml(
                row.overdue_days
            )}
                    </td>

                    <td>
                        ${escapeHtml(
                row.followup
            )}
                    </td>

                    <td>
                        ${escapeHtml(
                row.ep
            )}
                    </td>

                    <td>
                        ${escapeHtml(
                row.category
            )}
                    </td>

                    <td>
                        ${escapeHtml(
                row.fy
            )}
                    </td>
                </tr>
            `).join('');
    }

    async function openCardDetail(
        type,
        item
    ) {
        const value =
            String(
                item?.label || ''
            ).trim();

        if (!value) {
            return;
        }

        const titles = {
            followup: 'Followup Wise',
            category: 'Category Wise',
            ep: 'EP Wise',
            fy: 'Financial Year'
        };

        if (dialogTitle) {
            dialogTitle.textContent =
                titles[type] || 'Details';
        }

        if (dialogSubtitle) {
            dialogSubtitle.textContent =
                value;
        }

        if (dialogCount) {
            dialogCount.textContent =
                '—';
        }

        if (dialogTotal) {
            dialogTotal.textContent =
                '₹ —';
        }

        if (dialogStatus) {
            dialogStatus.textContent =
                'Loading records...';
        }

        if (dialogBody) {
            dialogBody.innerHTML = '';
        }

        openDialog();

        try {

            const response =
                await fetch(
                    `/api/dashboard/card-detail?type=${encodeURIComponent(type)
                    }&value=${encodeURIComponent(value)
                    }`,
                    {
                        method: 'GET',
                        headers: {
                            'Accept':
                                'application/json'
                        }
                    }
                );

            if (!response.ok) {
                throw new Error(
                    `Server returned ${response.status}`
                );
            }

            const result =
                await response.json();

            if (!result.success) {
                throw new Error(
                    result.message ||
                    'Unable to load records.'
                );
            }

            if (dialogCount) {
                dialogCount.textContent =
                    result.count ?? 0;
            }

            if (dialogTotal) {
                dialogTotal.textContent =
                    `₹ ${result.total_amount_display
                    || '0'
                    }`;
            }

            if (dialogStatus) {
                dialogStatus.textContent =
                    `${result.count || 0} record${result.count === 1
                        ? ''
                        : 's'
                    }`;
            }

            renderDetailRows(
                result.rows || []
            );

        } catch (error) {

            console.error(
                'Dashboard detail error:',
                error
            );

            if (dialogStatus) {
                dialogStatus.textContent =
                    error.message ||
                    'Unable to load details.';
            }

            if (dialogBody) {
                dialogBody.innerHTML = `
                    <tr>
                        <td
                            colspan="11"
                            class="dashboard-detail-error"
                        >
                            Unable to load records.
                        </td>
                    </tr>
                `;
            }
        }
    }

    if (dialogClose) {
        dialogClose.addEventListener(
            'click',
            closeDialog
        );
    }

    if (dialog) {
        dialog.addEventListener(
            'click',
            function (event) {

                if (
                    event.target === dialog
                ) {
                    closeDialog();
                }
            }
        );
    }

    document.addEventListener(
        'keydown',
        function (event) {

            if (
                event.key === 'Escape'
                &&
                dialog
                &&
                dialog.classList.contains(
                    'is-open'
                )
            ) {
                closeDialog();
            }
        }
    );

    // ==========================================================
    // BAR CHART
    // ==========================================================

    function drawBarChart(
        canvasId,
        rows,
        options = {}
    ) {
        const canvas =
            document.getElementById(
                canvasId
            );

        if (!canvas) {
            return;
        }

        const items =
            (rows || [])
                .filter(
                    item =>
                        Number(
                            item.total
                        ) > 0
                );

        // IMPORTANT:
        // Always reset chart hit areas.
        canvas._chartHits = [];

        const {
            ctx,
            width,
            height
        } = fitCanvas(canvas);

        ctx.clearRect(
            0,
            0,
            width,
            height
        );

        ctx.font =
            '12px Arial';

        ctx.fillStyle =
            '#607382';

        if (!items.length) {

            ctx.fillText(
                'No data available',
                12,
                24
            );

            return;
        }

        const left =
            options.left
                ? Number(options.left)
                : (
                    options.compact
                        ? 8
                        : 92
                );

        const right = 82;
        const top = 12;
        const rowGap = 8;

        const barHeight =
            Math.max(
                12,
                Math.min(
                    24,
                    (
                        height
                        - top
                        - rowGap *
                        (
                            items.length
                            - 1
                        )
                    )
                    / items.length
                )
            );

        const max =
            Math.max(
                ...items.map(
                    item =>
                        Number(
                            item.total
                        ) || 0
                )
            );

        const barWidth =
            Math.max(
                20,
                width
                - left
                - right
            );

        items.forEach(
            (item, index) => {

                const y =
                    top
                    + index *
                    (
                        barHeight
                        + rowGap
                    );

                const value =
                    Number(
                        item.total
                    ) || 0;

                const length =
                    max
                        ? (
                            value / max
                        ) * barWidth
                        : 0;

                ctx.fillStyle =
                    '#607382';

                if (!options.compact) {

                    label(
                        ctx,
                        item.label,
                        8,
                        y
                        + barHeight
                        - 5,
                        left - 14
                    );
                }

                ctx.fillStyle =
                    palette[
                    index
                    % palette.length
                    ];

                ctx.fillRect(
                    left,
                    y,
                    length,
                    barHeight
                );

                // ==================================================
                // CRITICAL FIX:
                // Store hit area for EVERY chart item.
                // Do NOT depend on item.url.
                // ==================================================

                canvas._chartHits.push({
                    x: 0,
                    y: y - 4,
                    width: width,
                    height:
                        barHeight + 8,
                    item: item
                });

                ctx.fillStyle =
                    '#203040';

                ctx.font =
                    '12px Arial';

                ctx.fillText(
                    money(value),
                    left
                    + length
                    + 8,
                    y
                    + barHeight
                    - 5
                );

                if (options.compact) {

                    ctx.fillStyle =
                        '#203040';

                    label(
                        ctx,
                        item.label,
                        left + 6,
                        y
                        + barHeight
                        - 5,
                        Math.max(
                            40,
                            length - 12
                        )
                    );
                }
            }
        );
    }

    // ==========================================================
    // DONUT CHART
    // ==========================================================

    function drawDonut(
        canvasId,
        rows
    ) {
        const canvas =
            document.getElementById(
                canvasId
            );

        if (!canvas) {
            return;
        }

        const items =
            (rows || [])
                .filter(
                    item =>
                        Number(
                            item.total
                        ) > 0
                );

        canvas._chartHits = [];

        const {
            ctx,
            width,
            height
        } = fitCanvas(canvas);

        ctx.clearRect(
            0,
            0,
            width,
            height
        );

        if (!items.length) {

            ctx.fillStyle =
                '#607382';

            ctx.fillText(
                'No data available',
                12,
                24
            );

            return;
        }

        const total =
            items.reduce(
                (
                    sum,
                    item
                ) =>
                    sum
                    + Number(
                        item.total || 0
                    ),
                0
            );

        const cx =
            Math.min(
                width * 0.3,
                120
            );

        const cy =
            height / 2;

        const radius =
            Math.min(
                height * 0.36,
                68
            );

        let start =
            -Math.PI / 2;

        items.forEach(
            (item, index) => {

                const angle =
                    total
                        ? (
                            Number(
                                item.total
                            ) / total
                        )
                        * Math.PI
                        * 2
                        : 0;

                ctx.beginPath();

                ctx.moveTo(
                    cx,
                    cy
                );

                ctx.arc(
                    cx,
                    cy,
                    radius,
                    start,
                    start + angle
                );

                ctx.closePath();

                ctx.fillStyle =
                    palette[
                    index
                    % palette.length
                    ];

                ctx.fill();

                // ==================================================
                // CRITICAL FIX:
                // Save geometry for donut click detection.
                // ==================================================

                canvas._chartHits.push({
                    item: item,
                    startAngle: start,
                    endAngle:
                        start + angle,
                    cx: cx,
                    cy: cy,
                    radius: radius,
                    innerRadius:
                        radius * 0.58
                });

                start += angle;
            }
        );

        // Inner circle
        ctx.beginPath();

        ctx.arc(
            cx,
            cy,
            radius * 0.58,
            0,
            Math.PI * 2
        );

        ctx.fillStyle =
            '#fff';

        ctx.fill();

        ctx.fillStyle =
            '#203040';

        ctx.font =
            '700 13px Arial';

        ctx.textAlign =
            'center';

        ctx.fillText(
            money(total),
            cx,
            cy + 4
        );

        ctx.textAlign =
            'left';

        // Legend
        const legendX =
            Math.min(
                width * 0.54,
                cx + radius + 35
            );

        items
            .slice(0, 6)
            .forEach(
                (item, index) => {

                    const y =
                        22
                        + index * 22;

                    ctx.fillStyle =
                        palette[
                        index
                        % palette.length
                        ];

                    ctx.fillRect(
                        legendX,
                        y - 10,
                        10,
                        10
                    );

                    ctx.fillStyle =
                        '#203040';

                    ctx.font =
                        '12px Arial';

                    label(
                        ctx,
                        `${item.label
                        } (${Math.round(
                            (
                                Number(
                                    item.total
                                ) / total
                            ) * 100
                        )
                        }%)`,
                        legendX + 16,
                        y,
                        width
                        - legendX
                        - 24
                    );
                }
            );
    }

    // ==========================================================
    // BAR HIT TEST
    // ==========================================================

    function getBarHit(
        canvas,
        event
    ) {
        const rect =
            canvas.getBoundingClientRect();

        const x =
            event.clientX
            - rect.left;

        const y =
            event.clientY
            - rect.top;

        return (
            canvas._chartHits || []
        ).find(
            hit =>
                x >= hit.x
                &&
                x <=
                hit.x
                + hit.width
                &&
                y >= hit.y
                &&
                y <=
                hit.y
                + hit.height
        );
    }

    // ==========================================================
    // DONUT HIT TEST
    // ==========================================================

    function getDonutHit(
        canvas,
        event
    ) {
        const rect =
            canvas.getBoundingClientRect();

        const x =
            event.clientX
            - rect.left;

        const y =
            event.clientY
            - rect.top;

        const hits =
            canvas._chartHits || [];

        for (const hit of hits) {

            const dx =
                x - hit.cx;

            const dy =
                y - hit.cy;

            const distance =
                Math.sqrt(
                    dx * dx
                    + dy * dy
                );

            if (
                distance < hit.innerRadius
                ||
                distance > hit.radius
            ) {
                continue;
            }

            let angle =
                Math.atan2(
                    dy,
                    dx
                );

            // Normalize to [0, 2π)
            angle =
                (
                    angle + Math.PI * 2
                )
                % (
                    Math.PI * 2
                );

            let start =
                (
                    hit.startAngle
                    + Math.PI * 2
                )
                % (
                    Math.PI * 2
                );

            let end =
                (
                    hit.endAngle
                    + Math.PI * 2
                )
                % (
                    Math.PI * 2
                );

            if (start <= end) {

                if (
                    angle >= start
                    &&
                    angle <= end
                ) {
                    return hit;
                }

            } else {

                if (
                    angle >= start
                    ||
                    angle <= end
                ) {
                    return hit;
                }
            }
        }

        return null;
    }

    // ==========================================================
    // RENDER
    // ==========================================================

    function render() {

        drawBarChart(
            'ageingChart',
            data.ageing || [],
            {
                compact: true
            }
        );

        drawBarChart(
            'followupChart',
            data.followup || []
        );

        drawDonut(
            'categoryChart',
            data.category || []
        );

        drawBarChart(
            'epChart',
            data.ep || []
        );

        drawBarChart(
            'fyChart',
            data.fy || [],
            {
                left: 150
            }
        );
    }

    render();

    window.addEventListener(
        'resize',
        render
    );

    // ==========================================================
    // CLICK + HOVER HANDLERS
    // ==========================================================

    const clickableCharts = {
        followupChart: 'followup',
        categoryChart: 'category',
        epChart: 'ep',
        fyChart: 'fy'
    };

    Object.entries(
        clickableCharts
    ).forEach(
        (
            [
                canvasId,
                type
            ]
        ) => {

            const canvas =
                document.getElementById(
                    canvasId
                );

            if (!canvas) {
                return;
            }

            // --------------------------------------------------
            // CLICK
            // --------------------------------------------------

            canvas.addEventListener(
                'click',
                function (event) {

                    let hit = null;

                    if (
                        canvasId
                        === 'categoryChart'
                    ) {

                        hit =
                            getDonutHit(
                                canvas,
                                event
                            );

                    } else {

                        hit =
                            getBarHit(
                                canvas,
                                event
                            );
                    }

                    if (
                        !hit
                        ||
                        !hit.item
                    ) {
                        return;
                    }

                    openCardDetail(
                        type,
                        hit.item
                    );
                }
            );

            // --------------------------------------------------
            // HOVER
            // --------------------------------------------------

            canvas.addEventListener(
                'mousemove',
                function (event) {

                    let hit = null;

                    if (
                        canvasId
                        === 'categoryChart'
                    ) {

                        hit =
                            getDonutHit(
                                canvas,
                                event
                            );

                    } else {

                        hit =
                            getBarHit(
                                canvas,
                                event
                            );
                    }

                    canvas.style.cursor =
                        hit
                            ? 'pointer'
                            : 'default';
                }
            );

            canvas.addEventListener(
                'mouseleave',
                function () {
                    canvas.style.cursor =
                        'default';
                }
            );
        }
    );
});