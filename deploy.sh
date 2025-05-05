#!/bin/bash

router=$1
fileName="./output/$1.rsc"

if [ ! -f "$fileName" ]; then
  echo "No configuration for '$1' found."
  exit
fi

echo "Deploying \"$router\"..."

scp $fileName $router:/$router.rsc > /dev/null
if [ $? -ne 0 ]; then
  echo "Failed uploading configuration to \"$router\". Exiting."
  exit
fi

echo "Configuration uploaded, importing..."
ssh $router import file=$router.rsc | grep -e successfully > /dev/null
if [ $? -ne 0 ]; then
  echo "Failed importing configuration to \"$router\". See \"output.log\". Exiting."
  exit
fi

rm -f output.log

echo "Done."
