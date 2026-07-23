CREATE TABLE IF NOT EXISTS work_items (
    id BIGSERIAL PRIMARY KEY,
    excel_sl INTEGER,
    work_name VARCHAR(500) NOT NULL,
    section VARCHAR(150),
    status VARCHAR(30) NOT NULL DEFAULT 'Not Started'
        CHECK (status IN ('Not Started', 'WIP', 'Done', 'On Hold')),
    work_inflow DATE,
    next_scheduled DATE,
    reschedule_scheduled DATE,
    target_date DATE,
    actual_completion_date DATE,
    remark TEXT,
    allotted_to VARCHAR(150),
    created_by_alias VARCHAR(150),
    deleted_at TIMESTAMPTZ,
    deleted_by_alias VARCHAR(150),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE work_items ADD COLUMN IF NOT EXISTS created_by_alias VARCHAR(150);
ALTER TABLE work_items ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;
ALTER TABLE work_items ADD COLUMN IF NOT EXISTS deleted_by_alias VARCHAR(150);

CREATE INDEX IF NOT EXISTS idx_work_items_status ON work_items(status);
CREATE INDEX IF NOT EXISTS idx_work_items_target_date ON work_items(target_date);
CREATE UNIQUE INDEX IF NOT EXISTS idx_work_items_excel_sl
    ON work_items(excel_sl) WHERE excel_sl IS NOT NULL;

CREATE TABLE IF NOT EXISTS work_notifications (
    id BIGSERIAL PRIMARY KEY,
    work_item_id BIGINT NOT NULL REFERENCES work_items(id) ON DELETE CASCADE,
    recipient_alias VARCHAR(150) NOT NULL,
    sender_alias VARCHAR(150) NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_work_notifications_recipient
    ON work_notifications(recipient_alias, is_read);
