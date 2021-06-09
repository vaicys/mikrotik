#!/bin/bash

if ! command -v j2 &> /dev/null; then
  echo "j2[cli] is not installed."
  echo "To install run: pip install j2cli[yaml]"
  exit
fi

if [ ! -f "secrets.yml" ]; then
  echo "Secrets file not found."
  exit
fi

mkdir -p output
rm -f output/*

for routerPath in routers/*; do
  router=$(basename $routerPath)

  pushd $routerPath > /dev/null

  if [ ! -f "main.rsc.j2" ]; then
    popd > /dev/null
    continue
  fi

  echo "Building router \"$router\" configuration."

  j2 main.rsc.j2 ../../secrets.yml -o ../../output/$router.rsc

  if [ $? -ne 0 ]; then
    echo "Failed to build router config for \"$router\". Exiting."
    popd > /dev/null
    exit
  fi

  echo "Configuration \"output/$router.rsc\" created."

  popd > /dev/null
done
