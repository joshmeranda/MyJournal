#!/usr/bin/env bash

source "$(dirname $0)/logger.sh"

if [ "$(id -u )" -ne 0 ]; then
    log_error must be run as root
    exit 1
fi

domains="$(vagrant global-status | tail -n +3 | head -n 2 | cut -d ' ' -f 1)"

log_info "destroying domains $domains"
vagrant destroy --force $domains