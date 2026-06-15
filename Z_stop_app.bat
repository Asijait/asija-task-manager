@echo off
setlocal
title Stop Asija App

echo.
echo Stopping Asija App server on port 5001...
echo.

set "FOUND_PID="

for /f "tokens=5" %%P in ('netstat -ano ^| findstr /r /c:":5001 .*LISTENING"') do (
    set "FOUND_PID=1"
    echo Stopping PID %%P
    taskkill /F /PID %%P /T
)

if not defined FOUND_PID (
    echo No running Asija App server found on port 5001.
) else (
    echo.
    echo Asija App server stopped.
)

echo.
echo If internet users still see old design after restart, ask them to hard refresh:
echo Ctrl + F5
echo.
pause
