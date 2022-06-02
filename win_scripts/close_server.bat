@echo off
set scriptpath=%~dp0
set  server_pid_path=%scriptpath%..\tmp\pids\server.pid

IF EXIST %server_pid_path% (
	cd %scriptpath%..
	docker-compose down
	cd %scriptpath%
)