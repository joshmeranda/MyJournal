#!/usr/bin/env bash

source "$(dirname "$0")/logger.sh"

if [ "$(id -u)" -ne 0 ]; then
    echo "must be run as root"
    exit 1
fi

ipxe_example_repo=https://github.com/harvester/ipxe-examples.git
ipxe_dir="$(dirname "$0")/resources/ipxe-examples"
ipxe_start_script="./vagrant-pxe-harvester/setup_harvester.sh"

if [ ! -e "$ipxe_dir" ]; then
  log_info "could not find ipxe-examples at '$ipxe_dir', cloning from '$ipxe_example_repo'"
  git clone "$ipxe_example_repo" "$ipxe_dir"
  log_info
  log_info 'this would be a good time to configure your ipxe-example repo'
  log_info 'it would probably also be a good idea to change the ownership of the repo'
  log_info
else
  log_info "using exising ipxe-examples found at '$ipxe_dir'"
fi

log_info 'starting harvester'
cd "$ipxe_dir"
"$ipxe_start_script"
