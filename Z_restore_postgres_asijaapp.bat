@echo off
setlocal
cd /d "%~dp0"

set "PG_BIN=C:\Program Files\PostgreSQL\18\bin"
set "PGHOST=localhost"
set "PGPORT=5432"
set "PGUSER=postgres"
set "PGPASSWORD=arif4004"
set "PGDATABASE=asijaapp"

if "%~1"=="" (
    echo.
    echo Drag and drop an asijaapp .sql backup file onto this restore file.
    echo Example backup folder: postgres_backups
    echo.
    pause
    exit /b 1
)

set "BACKUP_FILE=%~1"

echo.
echo WARNING: This will restore PostgreSQL database:
echo %PGDATABASE%
echo.
echo Backup file:
echo %BACKUP_FILE%
echo.
pause

"%PG_BIN%\psql.exe" -h %PGHOST% -p %PGPORT% -U %PGUSER% -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '%PGDATABASE%' AND pid <> pg_backend_pid();"
"%PG_BIN%\psql.exe" -h %PGHOST% -p %PGPORT% -U %PGUSER% -d postgres -c "DROP DATABASE IF EXISTS %PGDATABASE%;"
"%PG_BIN%\psql.exe" -h %PGHOST% -p %PGPORT% -U %PGUSER% -d postgres -c "CREATE DATABASE %PGDATABASE%;"
"%PG_BIN%\psql.exe" -h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE% -f "%BACKUP_FILE%"

if errorlevel 1 (
    echo.
    echo Restore failed.
    pause
    exit /b 1
)

echo.
echo Restore complete.
echo.
pause
