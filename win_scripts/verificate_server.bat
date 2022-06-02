
@echo off
set scriptpath=%~dp0
set logs_path=%scriptpath%logs.txt

:: Iniciar la base de datos del sistema novac
echo . >> %logs_path%
echo .. >> %logs_path%
echo proceso del dia: %date% %time% >> %logs_path%
echo .. >> %logs_path%
echo . >> %logs_path%
:: =========================================================================================================================================================
:: VERIFICAR QUE DOCKER ESTE EJECUTANDOSE
:: =========================================================================================================================================================
set count=1

:loop
	docker container ps > %scriptpath%temp_docker.txt
	cls
	echo .
	echo .

	IF %ERRORLEVEL% GTR 0	(

		echo - %count%: Servicio de docker no esta ejecutandose, esperando a que se inicie el servicio para continuar...
		IF %count% LSS 100	(
			set /a count+=1
			TIMEOUT 1  > nul
			echo - %count%: Servicio de docker no esta ejecutandose, esperando a que se inicie el servicio para continuar... >> %logs_path%
			goto loop
		)	ELSE	(
			goto docker_not_running
		)

	)	ELSE	(

		call %scriptpath%count_ocurrences.bat
		TIMEOUT 1  > nul

		set /p IS_FULL_RUNNING=<%scriptpath%temp_count.txt
		echo IS_FULL_RUNNING: %IS_FULL_RUNNING%
		TIMEOUT 1  > nul
		echo . >> %logs_path%
		echo ---- veces que aparece ports en temp-docker: %IS_FULL_RUNNING% >> %logs_path%

		IF %IS_FULL_RUNNING% GTR 0 (

		echo .
		echo  ========== Servicio de docker esta ejecutandose, puede continuar ==========
		echo .
		docker container ps -a

		call :verificate_data_base
		) ELSE (
			goto loop
		)

		exit /b 0
	)


:docker_not_running
	cls
	echo .
	echo  ========== Docker no se esta ejecutando no puede continuar ==========
	echo .

	echo . >> %logs_path%
	echo ========== Docker no se esta ejecutando no puede continuar ========== >> %logs_path%
	exit /b 1

:: =========================================================================================================================================================
:: PROCESO PARA EJECUTAR LA BASE DE DATOS
:: =========================================================================================================================================================

:verificate_data_base
	cls

	set server_pid_path=%scriptpath%..\tmp\pids\server.pid

	echo server_pid_path : %server_pid_path%
	echo .
	echo ======= INICANDO PROCESO =======
	echo .
	echo. >> %logs_path%
	echo ======= INICANDO PROCESO ======= >> %logs_path%

	IF EXIST %server_pid_path% (
		call :killProcess

		TIMEOUT 1  > nul
		call :runProcess

	)	ELSE	(
		echo ----- ARCHIVO SERVER.PID NO EXISTE CORRIENDO LA BASE DE DATOS -----
		echo. >> %logs_path%
		echo ----- ARCHIVO SERVER.PID NO EXISTE CORRIENDO LA BASE DE DATOS ----- >> %logs_path%
		call :runProcess
	)

	echo. >> %logs_path%
	echo ----- EJECUCION DEL SERVICIO PARA INICIAR BASE DE DATOS COMPLETADO ----- >> %logs_path%

	EXIT /B %ERRORLEVEL%


:strLen
	setlocal enabledelayedexpansion
	EXIT /B 0

:killProcess
	echo.
	echo ----- DETENIENDO EL DOCKER COMPOSE -----
	echo.
	echo. >> %logs_path%
	echo ----- DETENIENDO EL DOCKER COMPOSE EXISTENTE ----- >> %logs_path%
	call %scriptpath%close_server.bat

	EXIT /B %ERRORLEVEL%


:runProcess
	IF EXIST %scriptpath%run_server.bat (
		echo.
		echo ----- INICANDO CONTENEDORES DE DOCKER -----
		echo.
		echo. >> %logs_path%
		echo ----- INICANDO CONTENEDORES DE DOCKER ----- >> %logs_path%

		TIMEOUT 1  > nul
		call %scriptpath%run_server.bat
		EXIT /B %ERRORLEVEL%
	)	ELSE (
		echo.
		echo NO EXISTE RUN_SERVER
		echo.
		echo. >> %logs_path%
		echo ----- NO EXISTE RUN_SERVER ----- >> %logs_path%
		EXIT /B 1
	)

:errorInCommand
	echo. >> %logs_path%
	echo ----- OCURRIO IN ERROR EN EL PROCESO ANTERIOR NO SE PUEDE CONTINUAR ----- >> %logs_path%
	EXIT /B 0
