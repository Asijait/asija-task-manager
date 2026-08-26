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

            const apiBase =
                String(
                    window.DASHBOARD_API_BASE || ''
                ).replace(
                    /\/+$/,
                    ''
                );

            const response =
                await fetch(
                    `${apiBase}/api/dashboard/card-detail?type=${encodeURIComponent(type)}&value=${encodeURIComponent(value)}`,
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
                    `₹ ${result.total_amount_display || '0'}`;
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
    // DONUT / CATEGORY CHART
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

            ctx.font =
                '12px Arial';

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
                width * 0.34,
                105
            );

        const cy =
            height / 2;

        const radius =
            Math.min(
                height * 0.34,
                64
            );

        const innerRadius =
            radius * 0.58;

        let start =
            -Math.PI / 2;

        items.forEach(
            (
                item,
                index
            ) => {

                const value =
                    Number(
                        item.total || 0
                    );

                const angle =
                    total
                        ? (
                            value / total
                        )
                        * Math.PI
                        * 2
                        : 0;

                const end =
                    start + angle;

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
                    end
                );

                ctx.closePath();

                ctx.fillStyle =
                    palette[
                    index
                    % palette.length
                    ];

                ctx.fill();

                ctx.strokeStyle =
                    '#ffffff';

                ctx.lineWidth =
                    1.5;

                ctx.stroke();

                const percentage =
                    total
                        ? (
                            value / total
                        )
                        * 100
                        : 0;

                if (
                    percentage >= 5
                ) {

                    const middle =
                        start
                        + angle / 2;

                    const labelRadius =
                        (
                            radius
                            + innerRadius
                        ) / 2;

                    const labelX =
                        cx
                        + Math.cos(
                            middle
                        )
                        * labelRadius;

                    const labelY =
                        cy
                        + Math.sin(
                            middle
                        )
                        * labelRadius;

                    ctx.fillStyle =
                        '#203040';

                    ctx.font =
                        '700 11px Arial';

                    ctx.textAlign =
                        'center';

                    ctx.textBaseline =
                        'middle';

                    ctx.fillText(
                        `${Math.round(
                            percentage
                        )}%`,
                        labelX,
                        labelY
                    );
                }

                /*
                 * IMPORTANT:
                 * These exact properties are consumed
                 * by getDonutHit().
                 */
                canvas._chartHits.push({
                    type: 'donut',
                    startAngle: start,
                    endAngle: end,
                    cx: cx,
                    cy: cy,
                    radius: radius,
                    innerRadius: innerRadius,
                    item: item
                });

                start =
                    end;
            }
        );

        // ------------------------------------------------------
        // DONUT CENTRE
        // ------------------------------------------------------

        ctx.beginPath();

        ctx.arc(
            cx,
            cy,
            innerRadius,
            0,
            Math.PI * 2
        );

        ctx.fillStyle =
            '#ffffff';

        ctx.fill();

        ctx.fillStyle =
            '#203040';

        ctx.font =
            '700 11px Arial';

        ctx.textAlign =
            'center';

        ctx.textBaseline =
            'middle';

        ctx.fillText(
            money(total),
            cx,
            cy
        );

        // ------------------------------------------------------
        // EXTERNAL CATEGORY LABELS + TOTALS
        // ------------------------------------------------------

        items.forEach(
            (
                item,
                index
            ) => {

                const value =
                    Number(
                        item.total || 0
                    );

                const percentage =
                    total
                        ? value / total
                        : 0;

                const itemStart =
                    -Math.PI / 2
                    +
                    items
                        .slice(
                            0,
                            index
                        )
                        .reduce(
                            (
                                sum,
                                previous
                            ) =>
                                sum
                                +
                                (
                                    Number(
                                        previous.total
                                        || 0
                                    )
                                    / total
                                )
                                * Math.PI
                                * 2,
                            0
                        );

                const itemAngle =
                    percentage
                    * Math.PI
                    * 2;

                const middle =
                    itemStart
                    + itemAngle / 2;

                const labelStartRadius =
                    radius + 7;

                const labelX =
                    cx
                    + Math.cos(
                        middle
                    )
                    * labelStartRadius;

                const labelY =
                    cy
                    + Math.sin(
                        middle
                    )
                    * labelStartRadius;

                const isRight =
                    Math.cos(
                        middle
                    ) >= 0;

                const textX =
                    isRight
                        ? Math.min(
                            width - 8,
                            Math.max(
                                labelX + 8,
                                width * 0.50
                            )
                        )
                        : Math.max(
                            8,
                            Math.min(
                                labelX - 8,
                                width * 0.25
                            )
                        );

                ctx.beginPath();

                ctx.moveTo(
                    labelX,
                    labelY
                );

                ctx.lineTo(
                    textX,
                    labelY
                );

                ctx.strokeStyle =
                    '#aeb8bf';

                ctx.lineWidth =
                    1;

                ctx.stroke();

                ctx.fillStyle =
                    palette[
                    index
                    % palette.length
                    ];

                ctx.font =
                    '700 11px Arial';

                ctx.textAlign =
                    isRight
                        ? 'left'
                        : 'right';

                ctx.textBaseline =
                    'middle';

                const categoryLabel =
                    String(
                        item.label
                        || 'Unassigned'
                    );

                ctx.fillText(
                    categoryLabel,
                    textX,
                    labelY - 7
                );

                ctx.fillStyle =
                    '#203040';

                ctx.font =
                    '10px Arial';

                ctx.fillText(
                    money(value),
                    textX,
                    labelY + 7
                );
            }
        );

        ctx.textAlign =
            'left';

        ctx.textBaseline =
            'alphabetic';
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

    // FILE: debtorapp/static/js/dashboard.js
    //
    // REPLACE ONLY THE CURRENT getDonutHit() FUNCTION
    // WITH THIS VERSION.

    function getDonutHit(canvas, event) {
        const rect =
            canvas.getBoundingClientRect();

        /*
         * Use CSS/display coordinates.
         * This avoids devicePixelRatio / canvas backing-store
         * coordinate mismatches.
         */
        const x =
            event.clientX - rect.left;

        const y =
            event.clientY - rect.top;

        const hits =
            canvas._chartHits || [];

        if (!hits.length) {
            return null;
        }

        /*
         * The donut geometry is stored on every slice.
         */
        const first =
            hits[0];

        const dx =
            x - first.cx;

        const dy =
            y - first.cy;

        const distance =
            Math.sqrt(
                (dx * dx) +
                (dy * dy)
            );

        /*
         * Only the actual donut ring is clickable.
         */
        if (
            distance < first.innerRadius ||
            distance > first.radius
        ) {
            return null;
        }

        /*
         * Convert mouse position to angle.
         */
        let angle =
            Math.atan2(
                dy,
                dx
            );

        if (angle < 0) {
            angle += Math.PI * 2;
        }

        /*
         * Find the exact slice.
         */
        for (const hit of hits) {

            let start =
                hit.startAngle;

            let end =
                hit.endAngle;

            /*
             * Normalize angles.
             */
            start =
                (
                    start +
                    Math.PI * 2
                ) %
                (Math.PI * 2);

            end =
                (
                    end +
                    Math.PI * 2
                ) %
                (Math.PI * 2);

            /*
             * Slice crosses 0° / 360°.
             */
            if (end < start) {

                if (
                    angle >= start ||
                    angle <= end
                ) {
                    return hit;
                }

                continue;
            }

            /*
             * Normal slice.
             */
            if (
                angle >= start &&
                angle <= end
            ) {
                return hit;
            }
        }

        return null;
    }

    // ==========================================================
    // RENDER
    // ==========================================================

    function render() {

        /*
         * AGEING MIX
         * Uses the original bar-chart renderer.
         * Its click behaviour is handled separately
         * below and opens the original sub-report.
         */
        drawBarChart(
            'ageingChart',
            data.ageing || [],
            {
                compact: true
            }
        );

        /*
         * FOLLOWUP
         * New clickable dashboard dialog.
         */
        drawBarChart(
            'followupChart',
            data.followup || []
        );

        /*
         * CATEGORY
         * New clickable donut/dialog.
         */
        drawDonut(
            'categoryChart',
            data.category || []
        );

        /*
         * EP
         * New clickable dashboard dialog.
         */
        drawBarChart(
            'epChart',
            data.ep || []
        );

        /*
         * FINANCIAL YEAR
         * New clickable dashboard dialog.
         */
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
    // NEW CLICKABLE CHARTS
    //
    // IMPORTANT:
    // AGEING IS NOT INCLUDED HERE.
    // AGEING RETAINS ITS ORIGINAL REPORT BEHAVIOUR.
    // ==========================================================

    const clickableCharts = {
        categoryChart: 'category',
        epChart: 'ep',
        followupChart: 'followup',
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
                        canvasId === 'categoryChart'
                    ) {

                        hit =
                            getDonutHit(
                                canvas,
                                event
                            );

                        console.log(
                            'CATEGORY CLICK',
                            {
                                x:
                                    event.clientX -
                                    canvas.getBoundingClientRect().left,

                                y:
                                    event.clientY -
                                    canvas.getBoundingClientRect().top,

                                hits:
                                    canvas._chartHits,

                                hit:
                                    hit
                            }
                        );

                    } else {

                        hit =
                            getBarHit(
                                canvas,
                                event
                            );
                    }

                    if (
                        !hit ||
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

            // FILE: debtorapp/static/js/dashboard.js
            //
            // REPLACE THE CATEGORY mousemove HANDLER WITH THIS.

            canvas.addEventListener(
                'mousemove',
                function (event) {

                    let hit = null;

                    if (
                        canvasId === 'categoryChart'
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

    // ==========================================================
    // AGEING MIX
    //
    // PRESERVE ORIGINAL BEHAVIOUR.
    //
    // Clicking an ageing bar opens:
    //
    // /sub-report/detail?ageing=<label>
    //
    // using the URL generated by Flask.
    // ==========================================================

    const ageingCanvas =
        document.getElementById(
            'ageingChart'
        );

    if (ageingCanvas) {

        ageingCanvas.addEventListener(
            'click',
            function (event) {

                const hit =
                    getBarHit(
                        ageingCanvas,
                        event
                    );

                if (
                    !hit
                    ||
                    !hit.item
                ) {
                    return;
                }

                /*
                 * Flask already generates the correct
                 * application-prefixed URL.
                 *
                 * Example:
                 *
                 * /daily-debtor-report/sub-report/detail
                 * ?ageing=0-30+Days
                 */
                const url =
                    hit.item.url;

                if (!url) {
                    return;
                }

                window.open(
                    url,
                    '_blank',
                    'noopener,noreferrer'
                );
            }
        );

        ageingCanvas.addEventListener(
            'mousemove',
            function (event) {

                const hit =
                    getBarHit(
                        ageingCanvas,
                        event
                    );

                ageingCanvas.style.cursor =
                    (
                        hit
                        &&
                        hit.item
                        &&
                        hit.item.url
                    )
                        ? 'pointer'
                        : 'default';
            }
        );

        ageingCanvas.addEventListener(
            'mouseleave',
            function () {
                ageingCanvas.style.cursor =
                    'default';
            }
        );
    }
});