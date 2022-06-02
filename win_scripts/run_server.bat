@echo off

cd ..
docker-compose up -d
docker container ls -a
cd win_scripts
EXIT /B 0