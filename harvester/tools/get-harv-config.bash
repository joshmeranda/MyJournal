#!/usr/bin/env bash

usage="USAGE: $(basename $0) <ip>"

source "$(dirname $0)/logger.sh"

ip="$1"

if [ -z "$ip" ]; then
    echo -e "expected an ip but found none\n$usage"
    exit 1
fi

kubeconfig_path='/home/rancher/rke2.yaml'
local_kube_dir='/home/jmeranda/.kube'

log_info 'getting harv kubeconfig'
scp "rancher@$ip:$kubeconfig_path" "$local_kube_dir/config.harv"

log_info "making symlink '$local_kube_dir/config' to '$local_kube_dir/rke2.yaml'"
cd "$local_kube_dir"
if ! ln --force --symbolic config.harv config; then
    log_error "failed making symlink"
    exit 2
fi

log_info 'overwriting KUBECONFIG with cluster node ip'
sed --in-place "s/    server: https:\/\/127.0.0.1:6443/    server: https:\/\/$ip:6443/" config.harv