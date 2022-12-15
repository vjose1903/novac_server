#!/bin/bash

green=$(tput setaf 2)
red=$(tput setaf 1)
white=$(tput setaf 7)
yellow=$(tput setaf 3)
cyan=$(tput setaf 6)

OPTIONS="waptc:buds"
PRODUCTION='no'
BACKGROUND='no'

getActualClient() {
  cliente=$(cat config_setup/actual_cliente.txt)
  echo " "
  echo "${green} ||-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=||"
  echo "${green} ||          ${white}CLIENTE ACTUAL${green}          ||"
  echo "${green} ||-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=||"
  echo " "
  echo "${white}  $cliente"
  echo " "
}

setClient() {
  client=$OPTARG

  echo "${cyan}setClient >> ${client}"
  echo "${white} "

	if [ "$PRODUCTION" == "yes" ]; then environment_selected='prod'; else environment_selected='dev'; fi

  if [ "$client" == "agrodemi" -o "$client" == "brendy" -o "$client" == "vasquez" ]; then
    ruby ./setup.rb $client $environment_selected
  else
    echo "${red}*************************************"
    echo "${red}**                                 **"
    echo "${red}**      CLIENTE NO ENCONTRADO      **"
    echo "${red}**                                 **"
    echo "${red}*************************************"
    exit 2
  fi
}

dockerCommand() {
  command=$1

  echo "${cyan}command >> ${command}"
  echo "${white} "

  if [ "$command" == "up" -a "$BACKGROUND" == "yes" ]; then is_background='-d'; else is_background=''; fi

  if [ "$PRODUCTION" == "yes" ]; then
    docker-compose -f docker-compose.prod.yml $command $is_background
  else
    docker-compose $command $is_background
  fi
}

while getopts $OPTIONS opt; do
  echo " "

  case "${opt}" in
  w)
    echo "la opcion -w"
    docker system prune -f
  ;;
  a)
    echo "la opcion -a"
    getActualClient
  ;;
  p)
    echo "la opcion -p"
    PRODUCTION='yes'
    echo "${white} "
    echo "${yellow} -=-=-=- EJECUTANDO EN PRODUCCION -=-=-=-${white}"
    echo "${white} "
  ;;
  t)
    echo "la opcion -t"
    BACKGROUND='yes'
    ;;
  c)
    echo "la opcion -c"
    setClient
    ;;
  b)
    echo "la opcion -b"
    dockerCommand build
    ;;
  u)
    echo "la opcion -u"
    dockerCommand up
    ;;
  d)
    echo "la opcion -d"
    dockerCommand down
    ;;
  s)
    echo "la opcion -s"
    dockerCommand stop
    ;;
  *)
    echo "${red}*************************************"
    echo "${red}**                                 **"
    echo "${red}**        FLAG NO PERMITIDO        **"
    echo "${red}**                                 **"
    echo "${red}*************************************"
    exit 2
    ;;
  esac
done

