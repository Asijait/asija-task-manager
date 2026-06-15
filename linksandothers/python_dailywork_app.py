import sqlite3
import mysql.connector
import json
import os
from flask import Flask, render_template, request, jsonify, send_file
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# --- CONFIGURATIONS ---
DB_SQLITE = 'mywork.db'
MYSQL_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "password", # Apna MySQL password yahan likhein
    "database": "mywork"
}

# --- 1. DATABASE CONNECTION HELPER ---
def get_db_connection():
    conn = sqlite3.connect(DB_SQLITE)
    conn.row_factory = sqlite3.Row  # Dictionary format ke liye
    return conn

# --- 2. MIGRATION LOGIC (MySQL to SQLite) ---
def migrate_data_if_needed():
    # Always ensure tables exist, especially the new daily_diary table
    conn = sqlite3.connect(DB_SQLITE)
    cursor = conn.cursor()
    cursor.execute('''CREATE TABLE IF NOT EXISTS daily_diary (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entry_date TEXT,
        particulars TEXT,
        start_t TEXT,
        end_t TEXT,
        spend_time TEXT,
        remark TEXT
    )''')
    # Add columns if they don't exist in an older database
    try: cursor.execute("ALTER TABLE daily_diary ADD COLUMN start_t TEXT")
    except: pass
    try: cursor.execute("ALTER TABLE daily_diary ADD COLUMN end_t TEXT")
    except: pass
    conn.commit()
    conn.close()

    if not os.path.exists(DB_SQLITE):
        print("SQLite file nahi mili. Data migrate ho raha hai...")
        try:
            # MySQL Connection
            m_conn = mysql.connector.connect(**MYSQL_CONFIG)
            m_cursor = m_conn.cursor(dictionary=True)
            s_conn = sqlite3.connect(DB_SQLITE)
            s_cursor = s_conn.cursor()

            # Create Tables
            s_cursor.execute('''CREATE TABLE IF NOT EXISTS dailywork (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                inflowdate TEXT,
                work_name TEXT,
                target_date TEXT,
                status TEXT,
                allocated_to TEXT,
                total_seconds INTEGER
            )''')

            s_cursor.execute('''CREATE TABLE IF NOT EXISTS important_links (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                category TEXT,
                link_name TEXT,
                url TEXT,
                is_special INTEGER
            )''')

            # Transfer dailywork
            m_cursor.execute("SELECT * FROM dailywork")
            for row in m_cursor.fetchall():
                s_cursor.execute("INSERT INTO dailywork (inflowdate, work_name, target_date, status, allocated_to, total_seconds) VALUES (?, ?, ?, ?, ?, ?)",
                                 (str(row['inflowdate']), row['work_name'], str(row['target_date']), row['status'], row['allocated_to'], row['total_seconds']))

            # Transfer links
            m_cursor.execute("SELECT * FROM important_links")
            for row in m_cursor.fetchall():
                s_cursor.execute("INSERT INTO important_links (category, link_name, url, is_special) VALUES (?, ?, ?, ?)",
                                 (row['category'], row['link_name'], row['url'], row['is_special']))

            s_conn.commit()
            m_conn.close()
            s_conn.close()
            print("Migration Successful! 'mywork.db' ban gayi hai.")
        except Exception as e:
            print(f"Migration Error: {e}")

# --- 3. ROUTES ---

@app.route('/')
def index():
    try:
        conn = get_db_connection()
        status_query = request.args.get('status', 'All')
        user_query = request.args.get('user', 'All')

        # Get Sidebar Links
        db_links = conn.execute("SELECT * FROM important_links ORDER BY category").fetchall()
        
        # Get Categories
        categories_list = [row['category'] for row in conn.execute("SELECT DISTINCT category FROM important_links ORDER BY category").fetchall()]
        
        # Build Task Query
        query = "SELECT * FROM dailywork WHERE 1=1"
        params = []
        if status_query != 'All':
            query += " AND status = ?"
            params.append(status_query)
        if user_query != 'All':
            query += " AND allocated_to = ?"
            params.append(user_query)
        
        query += " ORDER BY id DESC"
        tasks = conn.execute(query, params).fetchall()
        conn.close()
        
        return render_template('index.html', sidebar_links=db_links, tasks=tasks, categories=categories_list)
    except Exception as e:
        print(f"Error: {e}")
        return render_template('index.html', sidebar_links=[], tasks=[], categories=[])

@app.route('/links-and-others')
def links_and_others():
    """Sirf Sidebar aur Links dikhane ke liye route"""
    return index()

@app.route('/diary')
def diary_page():
    # This route serves the separate diary page
    return render_template('diary.html')

@app.route('/get_tasks', methods=['GET'])
def get_tasks():
    try:
        conn = get_db_connection()
        tasks = conn.execute("SELECT inflowdate, work_name, target_date, status, allocated_to, total_seconds FROM dailywork ORDER BY id DESC").fetchall()
        # Convert sqlite row to list of dicts for JSON
        result = [dict(row) for row in tasks]
        conn.close()
        return jsonify(result)
    except Exception as e:
        return jsonify([])

@app.route('/save_tasks', methods=['POST'])
def save_tasks():
    try:
        data = request.json
        conn = get_db_connection()
        conn.execute("DELETE FROM dailywork") 
        
        for item in data:
            conn.execute("INSERT INTO dailywork (inflowdate, work_name, target_date, status, allocated_to, total_seconds) VALUES (?, ?, ?, ?, ?, ?)",
                         (item['eDate'], item['wName'], item['tDate'], item['status'], item.get('allocatedTo', ''), item.get('totalSeconds', 0)))
        
        conn.commit()
        conn.close()
        return jsonify({"status": "success"})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)})

@app.route('/get_diary', methods=['GET'])
def get_diary():
    try:
        conn = get_db_connection()
        rows = conn.execute("SELECT * FROM daily_diary ORDER BY id ASC").fetchall()
        result = [dict(row) for row in rows]
        conn.close()
        return jsonify(result)
    except Exception as e:
        return jsonify([])

@app.route('/save_diary', methods=['POST'])
def save_diary():
    try:
        data = request.json
        conn = get_db_connection()
        # For simplicity, we clear and re-insert (similar to your existing save logic)
        conn.execute("DELETE FROM daily_diary") 
        
        for item in data:
            conn.execute("INSERT INTO daily_diary (entry_date, particulars, start_t, end_t, spend_time, remark) VALUES (?, ?, ?, ?, ?, ?)",
                         (item['date'], item['particulars'], item['start_t'], item['end_t'], item['spend_time'], item['remark']))
        
        conn.commit()
        conn.close()
        return jsonify({"status": "success"})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)})

@app.route('/backup_db', methods=['GET'])
def backup_db():
    # SQLite backup is simple: just send the file!
    try:
        return send_file(DB_SQLITE, as_attachment=True)
    except Exception as e:
        return str(e)

@app.route('/add_link', methods=['POST'])
def add_link():
    try:
        data = request.form
        conn = get_db_connection()
        conn.execute("INSERT INTO important_links (category, link_name, url, is_special) VALUES (?, ?, ?, ?)",
                     (data.get('category'), data.get('link_name'), data.get('url'), 1 if data.get('is_special') else 0))
        conn.commit()
        conn.close()
        return """<script>alert('Link Added!'); window.location.href='/';</script>"""
    except Exception as e:
        return f"Error: {e}"

@app.route('/delete_link/<int:link_id>', methods=['DELETE'])
def delete_link(link_id):
    try:
        conn = get_db_connection()
        conn.execute("DELETE FROM important_links WHERE id = ?", (link_id,))
        conn.commit()
        conn.close()
        return jsonify({"status": "success"})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500
    
    
@app.route('/edit_link', methods=['POST'])
def edit_link():
    try:
        # Form se data nikalna
        link_id = request.form.get('link_id')
        category = request.form.get('category')
        link_name = request.form.get('link_name')
        url = request.form.get('url')
        is_special = 1 if request.form.get('is_special') else 0

        conn = get_db_connection()
        # Database mein update query chalana
        conn.execute("""
            UPDATE important_links 
            SET category = ?, link_name = ?, url = ?, is_special = ? 
            WHERE id = ?
        """, (category, link_name, url, is_special, link_id))
        
        conn.commit()
        conn.close()
        return """<script>alert('Link Updated!'); window.location.href='/';</script>"""
    except Exception as e:
        return f"Error updating link: {e}"

# --- RUN APP ---
if __name__ == '__main__':
    migrate_data_if_needed() # App start hone se pehle migration check karega
    app.run(debug=True, port=5001)