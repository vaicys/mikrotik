#!/bin/bash

if ! command -v jinja2 &> /dev/null; then
  echo "jinja2 cli is not installed."
  echo "To install run: pip install jinja2-cli[yaml]"
  exit
fi

if [ ! -f "secrets.yml" ]; then
  echo "Secrets file not found."
  exit
fi

mkdir -p output
rm -f output/*

for routerPath in routers/*.rsc.j2; do
  buildFile=$(basename $routerPath)
  router=${buildFile%%.*}

  echo "Building router \"$router\" configuration."

  jinja2 --strict ./$routerPath secrets.yml -o ./output/$router.rsc

  if [ $? -ne 0 ]; then
    echo "Failed to build router config for \"$router\". Exiting."
    exit
  fi

  echo "Configuration \"output/$router.rsc\" created."
done
