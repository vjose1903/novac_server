
@echo off

:: Iniciar la base de datos del sistema novac

:: =========================================================================================================================================================
:: VERIFICAR QUE DOCKER ESTE EJECUTANDOSE
:: =========================================================================================================================================================
set count=1

:loop
	docker container ps -a
	cls
	echo .
	echo .

	IF %ERRORLEVEL% EQU 1	(

		echo - %count%: Servicio de docker no esta ejecutandose, esperando a que se inicie el servicio para continuar...
		IF %count% LSS 100	(
			set /a count+=1
			TIMEOUT 1  > nul
			echo - %count%: Servicio de docker no esta ejecutandose, esperando a que se inicie el servicio para continuar... >> logs.txt
			goto loop
		)	ELSE	(
			goto docker_not_running
		)

	)	ELSE	(
		echo .
		echo  ========== Servicio de docker esta ejecutandose, puede continuar ==========
		echo .
		docker container ps -a
		TIMEOUT 1 > nul
		call :verificate_data_base
		exit /b 0
	)


:docker_not_running
	cls
	echo .
	echo  ========== Docker no se esta ejecutando no puede continuar ==========
	echo .

	echo . >> logs.txt
	echo ========== Docker no se esta ejecutando no puede continuar ========== >> logs.txt
	exit /b 1

:: =========================================================================================================================================================
:: PROCESO PARA EJECUTAR LA BASE DE DATOS
:: =========================================================================================================================================================

:verificate_data_base
	cls
	set server_pid_path=..\tmp\pids\server.pid
	echo .
	echo ======= INICANDO PROCESO =======
	echo .
	echo. >> logs.txt
	echo ======= INICANDO PROCESO ======= >> logs.txt

	IF EXIST %server_pid_path% (
		call :killProcess
		TIMEOUT 1  > nul
		call :runProcess

	)	ELSE	(
		echo ----- ARCHIVO SERVER.PID NO EXISTE CORRIENDO LA BASE DE DATOS -----
		echo. >> logs.txt
		echo ----- ARCHIVO SERVER.PID NO EXISTE CORRIENDO LA BASE DE DATOS ----- >> logs.txt
		call :runProcess
	)

	echo. >> logs.txt
	echo ----- EJECUCION DEL SERVICIO PARA INICIAR BASE DE DATOS COMPLETADO ----- >> logs.txt

	EXIT /B %ERRORLEVEL%


:strLen
	setlocal enabledelayedexpansion
	EXIT /B 0

:killProcess
	echo.
	echo ----- DETENIENDO EL DOCKER COMPOSE -----
	echo.
	echo. >> logs.txt
	echo ----- DETENIENDO EL DOCKER COMPOSE EXISTENTE ----- >> logs.txt
	call close_server.bat
	EXIT /B 0


:runProcess
	IF EXIST run_server.bat (
		echo.
		echo ----- INICANDO CONTENEDORES DE DOCKER -----
		echo.
		echo. >> logs.txt
		echo ----- INICANDO CONTENEDORES DE DOCKER ----- >> logs.txt

		TIMEOUT 1  > nul
		call run_server.bat
	)	ELSE (
		echo.
		echo NO EXISTE RUN_SERVER
		echo.
		echo. >> logs.txt
		echo ----- NO EXISTE RUN_SERVER ----- >> logs.txt
	)
	EXIT /B 0
