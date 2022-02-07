@echo off

SET "arguments=%*"

SET is_instalar=%false%
SET is_actualizar=%false%


@REM FOR %%C in (%arguments:'=%) DO (
@REM 	echo " -->( %%C)"
@REM 	%parametro_en_turno=%%C
@REM   @REM 2>NUL CALL :CASE_%%C # jump to :CASES
@REM   @REM IF ERRORLEVEL 1 CALL :DEFAULT_CASE # parametro desconocido
@REM )



:CASE_i
  echo instalar
:CASE_a
  echo actualizar
:DEFAULT_CASE
  ECHO Parametro desconocido "%COLOR%"
  GOTO END_CASE
:END_CASE
  VER > NUL # reset ERRORLEVEL
  exit 0




@REM set is_instalar=%1
@REM set is_actualizar=%2


@REM IF [%is_instalar%] equ [] IF "%is_instalar%" neq "-i" (
@REM @REM IF %is_instalar% neq "-i" IF [%is_instalar%] neq [](
@REM     echo --- PARAMETRO CORRECTO ---
@REM     exit 0
@REM ) ELSE (
@REM     echo --- PARAMETRO INCORRECTO ---
@REM     exit 0
@REM )

:Start2 
    cls
    goto Start
    :Start
    echo ---------------------------------------
    echo           ACTUALIZAR PROGRAMA          
    echo ---------------------------------------           

    if %input% equ %one% goto Z if NOT goto Start2
    if %input% geq %four% goto N

    :Z
    cls
    echo You have selected year : 2017
    set year=2017
    echo %year%
    call:branches year

    pause
    exit

    :N
    cls
    echo Invalid Selection! Try again
    pause
    goto :start2
