use strict;
@echo off

SET "arguments=%*"

goto fin

:fin
  echo ------------------------------------
  echo          FINAL DE DEPLOY
  echo ------------------------------------

:onError
  echo ------------------------------------
  echo          ERROR EN DEPLOY
  echo ------------------------------------

:inicio
  echo ------------------------------------
  echo         INICIO DE DEPLOY
  echo ------------------------------------