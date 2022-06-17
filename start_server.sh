#!/bin/bash

green=$(tput setaf 2)
red=$(tput setaf 1)
white=$(tput setaf 7)
yellow=$(tput setaf 3)
cyan=$(tput setaf 6)

OPTIONS="aptc:buds"
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
  if [ "$client" == "agrodemi" -o "$client" == "brendy" ]; then
    ruby ./setup.rb $client
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
  a)
    echo "la opcion -a"
		getActualClient
  ;;
  p)
    echo "la opcion -p"
    PRODUCTION='yes'
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
