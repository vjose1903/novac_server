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

echo "Verificando días festivos de República Dominicana..."
if bundle exec rails calendar:holidays:ensure_next_three_years; then
	echo "Verificación de días festivos completada."
else
	echo "ADVERTENCIA: No fue posible sincronizar los días festivos."
	echo "El servidor continuará iniciando normalmente."
fi

export PORT="${PORT:-3000}"
exec bundle exec puma -C config/puma.rb


