@echo off

set scriptpath=%~dp0

cd %scriptpath%..
docker-compose up -d
docker container ls -a
cd %scriptpath%
EXIT /B 0