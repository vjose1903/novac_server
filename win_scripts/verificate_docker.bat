@echo off
set count=1

:loop
	docker container ps > temp_docker.txt
	cls
	echo .
	echo .
	IF %ERRORLEVEL% EQU 1	(

		echo - %count%: Servicio de docker no esta ejecutandose, esperando a que se inicie el servicio para continuar...
		IF %count% LSS 5	(
			set /a count+=1
			TIMEOUT 1  > nul
			echo - %count%: Servicio de docker no esta ejecutandose, esperando a que se inicie el servicio para continuar... >> logs.txt
			goto loop
		)	ELSE	(
			goto docker_not_running
		)

	)	ELSE	(
		echo aqui
		call count_ocurrences.bat
		TIMEOUT 1  > nul
		echo aqui tambien

		set /p IS_FULL_RUNNING=<temp_count.txt

		echo ------ %IS_FULL_RUNNING%

		IF %IS_FULL_RUNNING% GTR 0 (

		echo .
		echo  ========== Servicio de docker esta ejecutandose, puede continuar ==========
		echo .
		docker container ps -a

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

	echo . >> logs.txt
	echo ========== Docker no se esta ejecutando no puede continuar ========== >> logs.txt
	exit /b 1