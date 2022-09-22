#!/usr/bin/env bash

function logi {
    echo "[info] $@"
}

function logw {
    echo "[warn] $@"
}

HARV_USER='rancher'
HARV_HOME='/home/rancher'

SOURCE_KUBECONFIG='/etc/rancher/rke2/rke2.yaml'
KUBECONFIG="$HARV_HOME/rke2.yaml"

HARV_BASHRC="$HARV_HOME/.bashrc"

if [ -e "$KUBECONFIG" ]; then
    logi harvester system already setup
    exit 0
fi

logi "copying '$SOURCE_KUBECONFIG' -> '$KUBECONFIG'"
sudo cp "$SOURCE_KUBECONFIG" "$KUBECONFIG"
sudo chown "$HARV_USER:$HARV_USER" "$KUBECONFIG"
chmod 600 "$KUBECONFIG"

logi "populating '$HARV_BASHRC'"
echo -e "\nalias ls='ls -l -h --color=auto --group-directories-first'\nalias clr=clear\nalias cls='clear;ls'\nexport KUBECONFIG=\"$KUBECONFIG\"" >> "$HARV_BASHRC"
