#!/usr/bin/env bash

usage="USAGE: $(basename $0) <artifacts_dir> [destination_dir]"

source "$(dirname $0)/logger.sh"

artifacts_dir="$1"
destination_dir="$(xdg-user-dir DOWNLOAD)/harvester-artifacts"

if [ -z "$artifacts_dir" ]; then
    echo -e "expected artifacts dir, but found none\n$usage"
fi

if [ -n "$2" ]; then
    destination_dir="$2"
fi

if [ ! -d "$artifacts_dir" ]; then
    log_error "given artifact dir '$artifacts_dir' does not exist"
    exit 1
fi

cp_artifact_pattern() {
    pattern="$1"
    new_name="$2"

    artifact="$(find "$artifacts_dir" -name "$pattern")"

    if [ ! -f "$artifact" ]; then
        log_error "could not find artifact matching pattern '$artifacts_dir/$pattern'"
        return
    fi

    log_info "copying artifact '$artifact' -> '$destination_dir/$new_name'"
    if ! cp "$artifact" "$destination_dir/$new_name"; then
        log_error "error copying artifact '$artifact'"
    fi
}

if [ -d "$destination_dir" ]; then
    rm "$destination_dir"/*
else
    mkdir --parents "$destination_dir"
fi

cp_artifact_pattern 'harvester-*-amd64.iso' 'harvester-master-amd64.iso' &
cp_artifact_pattern 'harvester-*-vmlinuz-amd64' 'harvester-master-vmlinuz-amd64' &
cp_artifact_pattern 'harvester-*-initrd-amd64' 'harvester-master-initrd-amd64' &
cp_artifact_pattern 'harvester-*-rootfs-amd64.squashfs' 'harvester-master-rootfs-amd64.squashfs' &

log_info 'waiting for all copies to finish'
wait
log_info done