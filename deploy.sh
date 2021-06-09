#!/bin/bash

if [ ! -d "output" ]; then
  echo "No configurations found."
  exit
fi

pushd output > /dev/null

for filename in *; do
  router="${filename%.*}"

  if [[ $1 == "--all" ]]; then
    echo "Deploying for \"$router\"..."
  else
    git diff-tree --no-commit-id --name-only -r HEAD | grep -e $router > /dev/null
    if [ $? -ne 0 ]; then
      continue
    fi
    echo "Changes detected for \"$router\". Deploying..."
  fi

  scp ./$filename $router:/$filename > /dev/null
  if [ $? -ne 0 ]; then
    echo "Failed uploading configuration to \"$router\". Exiting."
    popd > /dev/null
    exit
  fi

  echo "Configuration uploaded, importing..."

  ssh $router import file=$filename | grep -e successfully > /dev/null
  if [ $? -ne 0 ]; then
    echo "Failed importing configuration to \"$router\". See \"output.log\". Exiting."
    popd > /dev/null
    exit
  fi

  rm -f output.log

  echo "Done."
done

popd > /dev/null
