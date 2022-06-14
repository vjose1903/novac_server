#!/bin/bash

green=$(tput setaf 2)
red=$(tput setaf 1)
white=$(tput setaf 7)
yellow=$(tput setaf 3)
cyan=$(tput setaf 6)

OPTIONS="ptc:buds"
PRODUCTION='no'
BACKGROUND='no'
ERROR_CLIENT='no'

setClient() {
	client=$OPTARG

	echo "${cyan}setClient ... ${client}"
	echo "${white} "
	if [ "$client" == "agrodemi" -o "$client" == "brendy" ]; then
	ruby ./setup.rb $client
	else
		echo "${red}setClient ... no encontrado"
		echo "${white} "
		ERROR_CLIENT='yes'
	fi
}

dockerCommand() {
	echo "${cyan}command ... ${command}"
	echo "${white} "

	command=$1
	if [ "$command" == "up" -a "$BACKGROUND" == "yes" ]; then is_background='-d'; else is_background=''; fi

	if [ "$PRODUCTION" == "yes" ]; then
		docker-compose -f docker-compose.prod.yml $command $is_background
	else
		docker-compose $command $is_background
	fi
}

while getopts $OPTIONS opt; do
	echo "opciones => ${opt}"
	case "${opt}" in
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
		exit 2
		;;
	esac
done
