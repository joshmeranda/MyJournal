#!/usr/bin/env bash

source "$(dirname $0)/logger.sh"

if [ "$(id -u)" -ne 0 ]; then
    echo "must be run as root"
    exit 1
fi

vagrant_dir="$(dirname "$0")/resources/ipxe-examples/vagrant-pxe-harvester"
vagrant_file="$vagrant_dir/Vagrantfile"

if [ ! -e "$vagrant_file" ]; then
  log_info "could not find a Vagrantfile at '$vagrant_file', there is nothing to do"
  exit
fi

cd "$vagrant_dir" || exit 1

log_info 'checking for running domains'
domains="$(vagrant status --machine-readable | grep state, | grep running | cut --delimiter , --fields 2)"

if [ -z "$domains" ]; then
  log_info 'no running domains found, nothing to do'
  exit
fi

log_info "stopping domains: " $domains

vagrant destroy --force $domains