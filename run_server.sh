#!/bin/bash

export BACKEND_PORT="5432"
export BACKEND_HOST="localhost"
export BACKEND_USERNAME="postgres"
export BACKEND_PASSWORD="Vasquez1903"

OPTIONS="rcsmpl"
PRODUCTION="no"
RAKE="no"

echo "opciones => ${getopts}"
echo "opciones => ${opt}"

setNivel() {
  echo "setNivel ==> ${PRODUCTION}"

  if [ "${PRODUCTION}" == "yes" ]; then
    export RAILS_ENV=production
    export RAILS_SERVE_STATIC_FILES=true
    export DISABLE_DATABASE_ENVIRONMENT_CHECK=1
  else
    export RAILS_ENV=development
  fi
  echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
  echo " "
}

setRake() {
  echo "setRake ==> ${RAKE}"
  if [ "${RAKE}" != "no" ]; then
    rails db:environment:set

    if [ "${RAKE}" == "all" ]; then
      rake db:drop db:create db:migrate db:seed
    else
      rake db:$RAKE
    fi
  fi
  echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
  echo " "
}

while getopts $OPTIONS opt; do
  echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
  echo " "
  echo "opciones => ${opt}"
  case "${opt}" in
  r)
    echo "la opcion -r"

    rails db:environment:set
    RAKE="all"
    setRake

    ;;
  c)
    echo "la opcion -c"
    rails c

    ;;
  s)
    echo "la opcion -s"
    rails s -b 0.0.0.0 &

    ;;
  m)
    echo "la opcion -m"
    RAKE="migrate"
    setRake

    ;;
  l)
    echo "la opcion -l"
    RAKE="seed"
    setRake

    ;;
  p)
    echo "la opcion -p"
    PRODUCTION="yes"
    setNivel

    ;;
  *)
    exit 2
    ;;
  esac
done
