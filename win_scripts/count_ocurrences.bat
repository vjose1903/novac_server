@echo off
set scriptpath=%~dp0
set str=PORTS
set file=%scriptpath%temp_docker.txt
set cnt=0
for /f ^"eol^=^

delims^=^" %%a in ('"findstr /i "/c:%str%" %file%"') do set "ln=%%a"&call :countStr

echo %cnt% > temp_count.txt

exit /b

:countStr
	setlocal enableDelayedExpansion
	:loop
	if defined ln (
		set "ln2=!ln:*%str%=!"
		if "!ln2!" neq "!ln!" (
			set "ln=!ln2!"
			set /a "cnt+=1"
			goto :loop
		)
	)
	endlocal & set cnt=%cnt%
	exit /b
