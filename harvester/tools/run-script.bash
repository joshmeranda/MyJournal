#!/usr/bin/env bash

function logi {
    echo "[info] $@"
}

function logw {
    echo "[warn] $@"
}

function loge {
    echo "[error] $@"
}

USAGE="Usage: $(basename $0) <ip> <scipt>"

remote_ip="$1"
script_path="$2"

if [ -z "$remote_ip" ]; then
    loge expected an ip but found none: $USAGE
    exit 1
fi

if [ -z "$script_path" ]; then
    loge expected a script but found none: $USAGE
    exit 1
elif [ ! -e "$script_path" ]; then
    loge "no such file or directory found at '$script_path'"
    exit 2
fi

logi "running '$script_path' on machine at '$remote_ip'"
ssh "$remote_ip" 'bash -s' < "$script_path"
