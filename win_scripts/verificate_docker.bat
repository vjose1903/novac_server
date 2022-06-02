@echo off
set count=1

:loop
	docker container ps -a
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
		echo .
		echo  ========== Servicio de docker esta ejecutandose, puede continuar ==========
		echo .
		docker container ps -a
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