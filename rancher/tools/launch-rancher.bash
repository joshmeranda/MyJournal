#!/usr/bin/env bash

source "$(dirname "$0")/logger.sh"

usage="Usage: $(basename "$0") [-f] [-i <version>] [-e <env-file>]

args:
  -f       follow the container logs once deployed
  -i       the rancher docker image to use [rancher/rancher:latest]
  -e       the env file to pass to the docker container
"

follow_logs=false
image="rancher/rancher:latest"
cnt_name=rancher
docker_flags=(--detach --privileged --restart=unless-stopped --publish 80:80 --publish 443:443 --name "$cnt_name")

while [ $# -gt 0 ]; do
  case "$1" in
    -f)
      follow_logs=true
      ;;
    -e)
      rancher_env_file="$2"
      shift
      ;;
    *)
      echo "unrecognized argument '$1'"
      echo "$usage"
      ;;
  esac

  shift
done

if [ ! -f "$rancher_env_file" ]; then
  log_warning "no such env file at '$rancher_env_file'"
else
  log_info "reading rancher env from '$rancher_env_file'"
  docker_flags=("$docker_flags" --env-file "$rancher_env_file")

  log_debug
  while read -r line; do
    log_debug "$line"
  done<"$rancher_env_file"
  log_debug
fi

log_info launching rancher with image "'$image'"

# rm any existing rancher containers
if [ -n "$(docker container ls --quiet --all --filter "name=$cnt_name")" ]; then
  log_warning found existing rancher container, deleting
  docker container stop "$cnt_name" > /dev/null 2>&1
  docker container rm "$cnt_name" > /dev/null 2>&1
fi

log_info starting rancher container
if ! docker run "${docker_flags[@]}" $image 1> /dev/null; then
  log_error could not start container
  exit 2
fi

if ! "$(dirname "$0")/wf.sh" -m 12 -i 5 -p -o last-err curl localhost; then
  log_error "error waiting for rancher to start"
  exit 1
fi

default_password=$(docker logs $cnt_name 2>&1 | grep 'Bootstrap Password: ' | cut -d ' ' -f 6)
log_info default password: "'$default_password'"
password_file=rancher_password
echo "$default_password" > "$password_file"

# print informative info
log_info to access an interactive shell to the rancher image run: docker exec --interactive --tty $cnt_name bash

if $follow_logs; then
  log_info showing logs
  docker logs --follow_logs $cnt_name
else
  log_info to view and follow_logs logs run: docker logs --follow_logs $cnt_name
fi