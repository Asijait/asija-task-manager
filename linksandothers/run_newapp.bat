@echo off
cd /d "%~dp0"
:: Purane kisi bhi python ko band karne ke liye
taskkill /f /im python.exe >nul 2>&1
:: Naya project start
start /b python python_dailywork_app.py
timeout /t 5 /nobreak > nul
:: Address check kijiye (5001)
start http://127.0.0.1:5001
