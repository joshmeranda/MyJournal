#!/usr/bin/env sh

cntr_image=test:latest
cntr_name=test

# maps container port to host port (ie <container>:<host>)
cntr_ports=(
  "80:80"
)

if [ -n "$(docker container ls --all --filter "name=$cntr_name")" ]; then
  docker container rm "$cntr_name"
fi

docker run --name "$cntr_name" ${arr[@]/#/--publish } "$cntr_image"