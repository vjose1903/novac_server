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

export PORT="${PORT:-3002}"
exec bundle exec puma -C config/puma.rb


