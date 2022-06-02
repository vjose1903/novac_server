@echo off

set  server_pid_path=..\tmp\pids\server.pid

IF EXIST %server_pid_path% (
	cd ..
	docker-compose down
	cd win_scripts
)