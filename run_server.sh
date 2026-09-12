#!/usr/bin/env bash

set -e

if [ -e ./tmp/pids/server.pid ]; then
	echo "${red}*************************************"
	echo "${red}**                                 **"
	echo "${red}**           BORRANDO PID          **"
	echo "${red}**                                 **"
	echo "${red}*************************************"

	rm -f ./tmp/pids/server.pid
fi

service cron start

bundle exec whenever --update-crontab

# Mantiene disponibles los feriados del año actual y los próximos dos años.
# La tarea es idempotente: solo genera los años que todavía no tienen datos.
bundle exec rails calendar:holidays:ensure_next_three_years

export PORT="${PORT:-3002}"
exec bundle exec puma -C config/puma.rb


