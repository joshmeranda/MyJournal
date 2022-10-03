#!/usr/bin/env bash

source "$(dirname $0)/logger.sh"

if [ "$(id -u )" -ne 0 ]; then
    log_error must be run as root
    exit 1
fi

"$(dirname $0)/teardown-harvester.bash"

log_info "launching harvester"
"$(dirname $0)/launch-harvester.bash"

hosts_file="/home/jmeranda/.ssh/known_hosts"
log_info "removing 192.168.1.30 from '$hosts_file'"
sed --in-place "/192.168.1.30/d" "$hosts_file"

echo 'dont forget to run: tools/run-script.bash rancher@192.168.1.30 tools/setup-scripts/harv.bash; tools/get-harv-config.bash 192.168.1.30'