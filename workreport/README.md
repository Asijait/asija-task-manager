# WorkDesk — Work Status & Reminder

`workdetail.xlsx` ke columns par bana hua lightweight work tracker. Pending, overdue, due-today aur next 7 days reminders dashboard par dikhte hain.

## 1. PostgreSQL database banayein

```powershell
createdb -U postgres workreport
```

`.env.example` ki copy `.env` naam se banayein aur apna PostgreSQL password set karein:

```env
DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@localhost:5432/workreport
SECRET_KEY=any-long-random-text
PORT=5000
```

## 2. Python packages install karein

```powershell
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

## 3. Excel data import karein

Ye command table khud create karegi aur `workdetail.xlsx` ka data import karegi. Dobara chalane par same serial-number records update honge, duplicate nahi:

```powershell
python app.py --import workdetail.xlsx
```

## 4. App chalayein

```powershell
python app.py
```

Browser me <http://127.0.0.1:5000> kholein.

## Features

- Dashboard counts: open, overdue, due today, completed
- Pending, overdue, today aur next 7 days filters
- Work/person/remark search aur status filter
- Add, edit, delete aur one-click complete
- Target date ke basis par automatic visual reminders
- Existing Excel file se repeat-safe import
- Responsive mobile layout

## API

- `GET /api/work` — list/filter work
- `GET /api/summary` — dashboard totals
- `POST /api/work` — add work
- `PUT /api/work/<id>` — edit work
- `PATCH /api/work/<id>/complete` — complete work
- `DELETE /api/work/<id>` — delete work
