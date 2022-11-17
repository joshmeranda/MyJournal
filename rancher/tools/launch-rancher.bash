#!/usr/bin/env bash

source "$(dirname "$0")/logger.sh"

rancher_env_file="$(dirname "$0")/rancher.env"
image="rancher/rancher:latest"

usage="Usage: $(basename "$0") [-f] [-i <image>] [-e <env-file>]

args:
  -h              show this help text
  -f              follow the container logs once deployed
  -i <image>      the rancher docker image to use [$image]
  -e <env-file>   the env file to pass to the docker container [$rancher_env_file]
  -c <cert-dir>   mount the certs in the given directory
  -d              set the log level to debug
"

follow_logs=false
cnt_name=rancher
rancher_flags=(--detach --privileged --restart=unless-stopped --publish 80:80 --publish 443:443 --name "$cnt_name")

while [ $# -gt 0 ]; do
  case "$1" in
    -h)
      echo "$usage"
      exit
      ;;
    -f)
      follow_logs=true
      ;;
    -i)
      image="$2"
      shift
      ;;
    -e)
      rancher_env_file="$2"
      shift
      ;;
    -c)
      cert_dir="$(realpath "$2")"
      shift
      ;;
    -d)
      rancher_flags+=(--env CATTLE_DEBUG=true)
      rancher_flags+=(--env RANCHER_DEBUG=true)
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
  rancher_flags+=(--env-file)
  rancher_flags+=("$rancher_env_file")

  log_debug
  while read -r line; do
    log_debug "$line"
  done<"$rancher_env_file"
  log_debug
fi

if [ -n "$cert_dir" ]; then
  if [ ! -d "$cert_dir" ]; then
    log_error "could not find cert directory at '$cert_dir'"
    exit 1
  else
    log_info "using certs at '$cert_dir'"
  fi

  rancher_flags+=(--mount "type=bind,source=$cert_dir/cert.pem,target=/etc/rancher/ssl/cert.pem" \
                  --mount "type=bind,source=$cert_dir/key.pem,target=/etc/rancher/ssl/key.pem" \
                  --mount "type=bind,source=$cert_dir/ca.pem,target=/etc/rancher/ssl/cacerts.pem")
fi

# rm any existing rancher containers
if [ -n "$(docker container ls --quiet --all --filter "name=$cnt_name")" ]; then
  log_warning found existing rancher container, deleting
  docker container stop "$cnt_name" > /dev/null 2>&1
  docker container rm "$cnt_name" > /dev/null 2>&1
fi

log_info "starting rancher container with '$image'"
log_debug "rancher_args: ${rancher_flags[@]}"
if ! docker run "${rancher_flags[@]}" $image 1> /dev/null; then
  log_error could not start container
  exit 2
fi

if ! "$(dirname "$0")/wf.sh" -m 20 -i 5 -p -o last-err curl localhost; then
  log_error "error waiting for rancher to start"
  exit 1
fi

default_password=$(docker logs $cnt_name 2>&1 | grep 'Bootstrap Password: ' | cut -d ' ' -f 6)
log_info default password: "'$default_password'"
password_file=rancher_password
echo "$default_password" > "$password_file"

# todo: we can probably do this kubeconfig stuff while waiting for the container to start
# get kubeconfig
#rancher_kubeconfig=/etc/rancher/k3s/k3s.yaml
#cp_dst="$HOME/.kube/config.rancher"
#
#log_info "copying rancher kubeconfig '$rancher_kubeconfig' to '$cp_dst'"
#docker cp "$cnt_name:$rancher_kubeconfig" "$cp_dst"
#
#rancher_ip="$(docker container inspect --format '{{ .NetworkSettings.IPAddress }}' "$cnt_name")"
#log_info "pointing new rancher kubeconfig to container ip '$rancher_ip'"
#yq --inplace eval ".clusters[0].cluster.server |= \"$rancher_ip\"" "$cp_dst"

# print informative info
log_info to access an interactive shell to the rancher image run: docker exec --interactive --tty $cnt_name bash

if $follow_logs; then
  log_info showing logs
  docker logs --follow_logs $cnt_name
else
  log_info to view and follow_logs logs run: docker logs --follow_logs $cnt_name
fi
