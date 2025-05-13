sudo chown -R $USER ./proyects
sudo chown -R $USER ./proyects/novac-server

cd proyects/novac-server

echo ""
echo ""

git reset --h

echo ""
echo ""
echo "\e[95m  ======================================================================================= MOVERME A LA RAMA DEL CLIENTE \e[0m"
echo ""
git switch ADM

echo ""
echo ""
echo "\e[95m  ================================================================================================= DETENER EL PROYECTO \e[0m"
echo ""
node ./scripts/start.js -p -d

echo ""
echo ""
echo "\e[95m  ============================================================================================ BAJAR LOS CAMBIOS DE GIT \e[0m"
echo ""
git pull

echo ""
echo ""
echo "\e[95m  ===================================================================================== EJECUTAR NUEVAMENTE EL PROYECTO \e[0m"
echo ""
node ./scripts/start.js -w -p -c agrodemi -t -u