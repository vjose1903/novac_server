#!/bin/bash

green=$(tput setaf 2)
red=$(tput setaf 1)
white=$(tput setaf 7)
yellow=$(tput setaf 3)
cyan=$(tput setaf 6)

OPTIONS="lpscet:r:"
PRODUCTION='no'

setVariable() {
	echo "${yellow}setVariable ...  production (${PRODUCTION})"
	echo "${white} "

	export BACKEND_PORT="5432"
	export BACKEND_HOST="localhost"
	export BACKEND_USERNAME="postgres"
	export DATABASE_NAME="ADM"
	export BACKEND_PASSWORD="Vasquez1903"
	export RAILS_SHOW_LOG=true
	export PORT="3000"
}

setNivel() {
	echo "${yellow}setNivel ... production (${PRODUCTION})"
	echo "${white} "

	if [ "$PRODUCTION" == "yes" ]; then
		export RAILS_ENV=production
		export RAILS_SERVE_STATIC_FILES=true
		export DISABLE_DATABASE_ENVIRONMENT_CHECK=1
	fi

}

setRake() {
	plat=$OPTARG
	echo "${cyan}setRake ... ${plat}"
	echo "${white} "

	if [ "$plat" == "reset" -o "$plat" == "drop" -o "$plat" == "create" -o "$plat" == "migrate" -o "$plat" == "seed" ]; then
		echo "${green}setRake ... encontrado"
		echo "${white} "
		rails db:environment:set
		if [ "${plat}" == "reset" ]; then
			rake db:drop db:create db:migrate db:seed
		else
			rake db:$plat
		fi
	else
		echo "${red}setRake ... no encontrado"
		echo "${white} "
	fi
}

while getopts $OPTIONS opt; do
	echo "opciones => ${opt}"
	case "${opt}" in
	r)
		echo "la opcion -r"
		setRake
		;;
	c)
		echo "la opcion -c"
		rails c
		;;
	s)
		echo "la opcion -s"
		rails s -b 0.0.0.0 --port $PORT

		;;
	p)
		echo "la opcion -p"
		PRODUCTION="yes"
		setNivel
		;;
	l)
		echo "la opcion -l"
		export RAILS_SHOW_LOG=true
		;;
	e)
		echo "la opcion -e"
		setVariable
		;;
	*)
		exit 2
		;;
	esac
done
