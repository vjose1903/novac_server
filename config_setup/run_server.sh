#!/usr/bin/env bash

if [ -e ./tmp/pids/server.pid ]; then
	echo "${red}*************************************"
	echo "${red}**                                 **"
	echo "${red}**           BORRANDO PID          **"
	echo "${red}**                                 **"
	echo "${red}*************************************"

	rm ./tmp/pids/server.pid
fi

rails server -b 0.0.0.0 --port $$DB_PORT$$



