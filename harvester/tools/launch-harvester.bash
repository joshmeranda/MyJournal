#!/usr/bin/env bash

if [ "$(id -u)" -ne 0 ]; then
    echo "must be run as root"
    exit 1
fi

vagrant_pxe_start_script=/home/jmeranda/downloads/ipxe-examples/vagrant-pxe-harvester/setup_harvester.sh

cd "$(dirname $vagrant_pxe_start_script)"
"$vagrant_pxe_start_script"
