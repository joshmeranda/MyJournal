#!/usr/bin/env sh

cntr_image=test:latest
cntr_name=test

# maps container port to host port (ie <container>:<host>)
cntr_ports=(
  "80:80"
)

if [ -n "$(docker container ls --quiet --all --filter "name=$cntr_name")" ]; then
  docker container stop "$cntr_name"
  docker container rm "$cntr_name"
fi

# re-splitting here is fine since they are command line arguments and the port
# mappings don't container spaces
docker run --name "$cntr_name" ${arr[@]/#/--publish } "$cntr_image"