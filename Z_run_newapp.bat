@echo off
setlocal
cd /d "%~dp0"

:: Stop old Asija App server on port 5001
powershell -NoProfile -Command "Get-NetTCPConnection -LocalPort 5001 -State Listen -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -Unique | ForEach-Object { Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue }; Start-Sleep -Seconds 1" >nul 2>&1

:: PostgreSQL database for debtor report
set "APP_DATABASE_URL=postgresql://postgres:arif4004@localhost:5432/asijaapp?sslmode=disable"
set "DEBTOR_DATABASE_URL=postgresql://postgres:arif4004@localhost:5432/debtorapp?sslmode=disable"
set "PYTHON_EXE=%CD%\venv\Scripts\python.exe"
set "LOG_DIR=%CD%\logs"

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

if not exist "%PYTHON_EXE%" (
    echo Python not found: %PYTHON_EXE% > "%LOG_DIR%\asija_launcher.log"
    exit /b 1
)

set "STDOUT_LOG=%LOG_DIR%\asija_app_stdout.log"
set "STDERR_LOG=%LOG_DIR%\asija_app_stderr.log"
set "LAUNCHER_LOG=%LOG_DIR%\asija_launcher.log"

:: Naya project start. Keep this cmd process alive while Flask is running.
echo Starting Asija App from %CD% at %DATE% %TIME% > "%LAUNCHER_LOG%"
echo Python: %PYTHON_EXE% >> "%LAUNCHER_LOG%"
echo Stdout: %STDOUT_LOG% >> "%LAUNCHER_LOG%"
echo Stderr: %STDERR_LOG% >> "%LAUNCHER_LOG%"
"%PYTHON_EXE%" app.py > "%STDOUT_LOG%" 2> "%STDERR_LOG%"
echo Asija App stopped with errorlevel %ERRORLEVEL% at %DATE% %TIME% >> "%LAUNCHER_LOG%"
