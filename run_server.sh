#!/usr/bin/env bash

if [ -e ./tmp/pids/server.pid ]; then
	echo "${red}*************************************"
	echo "${red}**                                 **"
	echo "${red}**           BORRANDO PID          **"
	echo "${red}**                                 **"
	echo "${red}*************************************"

	rm ./tmp/pids/server.pid
fi

service cron start

whenever --update-crontab

rails server -b 0.0.0.0 --port 3002



