#!/usr/bin/env bash

OPTIONS="e:"


while getopts $OPTIONS opt; do
  echo " "

  case "${opt}" in
  e)
  # set -f # disable glob
  # IFS=' ' # split on space characters
  arguments=($OPTARG)
  echo "Number of arguments: ${#arguments[@]}"

  for i in "${arguments[@]}"; do
    echo -n " ${i},"
  done
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