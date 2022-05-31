@echo off


set /p pid=< .\tmp\pids\server.pid

echo EL PID DE LA APP: %pid%

taskkill /PID %pid% /F