@echo off
setlocal
cd /d "%~dp0"

set "PG_BIN=C:\Program Files\PostgreSQL\18\bin"
set "PGHOST=localhost"
set "PGPORT=5432"
set "PGUSER=postgres"
set "PGPASSWORD=arif4004"
set "PGDATABASE=asijaapp"

if not exist "postgres_backups" mkdir "postgres_backups"

for /f %%I in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "STAMP=%%I"
set "BACKUP_FILE=%CD%\postgres_backups\asijaapp_%STAMP%.sql"

echo.
echo Taking PostgreSQL backup...
echo Database: %PGDATABASE%
echo File: %BACKUP_FILE%
echo.

"%PG_BIN%\pg_dump.exe" -h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE% --clean --if-exists --no-owner --no-privileges -f "%BACKUP_FILE%"

if errorlevel 1 (
    echo.
    echo Backup failed.
    pause
    exit /b 1
)

echo.
echo Backup complete:
echo %BACKUP_FILE%
echo.
pause
