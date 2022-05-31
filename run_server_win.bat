@echo off
set RAILS_ENV=development
REM set RAILS_ENV=production
set RAILS_SERVE_STATIC_FILES=true
set DISABLE_DATABASE_ENVIRONMENT_CHECK=1

rails s -b 0.0.0.0 --port 3000

REM green=$(tput setaf 2)
REM red=$(tput setaf 1)
REM white=$(tput setaf 7)
REM yellow=$(tput setaf 3)
REM cyan=$(tput setaf 6)

REM OPTIONS="lpscet:r:"
REM PRODUCTION='no'
REM DOCKER='no'

REM setVariable() {
REM   echo "${yellow}setVariable ...  production (${PRODUCTION})"
REM   echo "${white} "

REM   export BACKEND_PORT="5432"
REM   export BACKEND_HOST="localhost"
REM   export BACKEND_USERNAME="postgres"
REM   export DATABASE_NAME="ADM"
REM   export BACKEND_PASSWORD="Vasquez1903"
REM   export RAILS_SHOW_LOG=true
REM   export PORT="3000"
REM }

REM setNivel() {
REM   echo "${yellow}setNivel ... production (${PRODUCTION})"
REM   echo "${white} "

REM   if [ "$PRODUCTION" == "yes" ]; then
REM     export RAILS_ENV=production
REM     export RAILS_SERVE_STATIC_FILES=true
REM     export DISABLE_DATABASE_ENVIRONMENT_CHECK=1
REM   fi

REM   if [ "$DOCKER" == "yes" ]; then
REM     export RAILS_ENV=docker_development
REM   fi
REM }

REM setRake() {
REM   plat=$OPTARG
REM   echo "${cyan}setRake ... ${plat}"
REM   echo "${white} "

REM   if [ "$plat" == "reset" -o "$plat" == "drop" -o "$plat" == "create" -o "$plat" == "migrate" -o "$plat" == "seed" ]; then
REM     echo "${green}setRake ... encontrado"
REM     echo "${white} "
REM     rails db:environment:set
REM     if [ "${plat}" == "reset" ]; then
REM       rake db:drop db:create db:migrate db:seed
REM     else
REM       rake db:$plat
REM     fi
REM   else
REM     echo "${red}setRake ... no encontrado"
REM     echo "${white} "
REM   fi
REM }

REM while getopts $OPTIONS opt; do
REM   echo "opciones => ${opt}"
REM   case "${opt}" in
REM   r)
REM     echo "la opcion -r"
REM     setRake
REM     ;;
REM   c)
REM     echo "la opcion -c"
REM     rails c
REM     ;;
REM   s)
REM     echo "la opcion -s"
REM     rails s -b 0.0.0.0 --port $PORT
REM     REM rails s -b 0.0.0.0 --port 3000
REM     REM rails s -b 0.0.0.0
REM     REM /home/vjose/.rvm/bin/rvm all do bundle exec puma -C config/puma.rb

REM     ;;
REM   p)
REM     echo "la opcion -p"
REM     PRODUCTION="yes"
REM     setNivel
REM     ;;
REM   d)
REM     echo "la opcion -d"
REM     DOCKER="yes"
REM     setNivel
REM     ;;
REM   l)
REM     echo "la opcion -l"
REM     export RAILS_SHOW_LOG=true
REM     ;;
REM   e)
REM     echo "la opcion -e"
REM     setVariable
REM     ;;
REM   *)
REM     exit 2
REM     ;;
REM   esac
REM done
