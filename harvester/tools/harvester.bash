#!/usr/bin/env bash

source "$(dirname $0)/logger.sh"

ipxe_dir="$(dirname "$0")/ipxe-examples"

usage="Usage: "$(dirname "$0")" [args] <command>

args:
	-h                  show this help text
	-e <ipxe-examples>  the directory to look for the ipxe-examples directory [$ipxe_dir]

commands:
	up                  launch a harvester cluster
	down                take down a harvester cluster
	releases            list harvester release version
	artifacts           list the current harvester artifacts
"

artifacts()
{
	local settings_file="$ipxe_dir/vagrant-pxe-harvester/settings.yml"

	log_info
	log_info "harvester_iso_url: '$(yq eval '.harvester_iso_url' "$settings_file")'"
	log_info "harvester_kernel_url: '$(yq eval '.harvester_kernel_url' "$settings_file")'"
	log_info "harvester_ramdisk_url: '$(yq eval '.harvester_ramdisk_url' "$settings_file")'"
	log_info "harvester_rootfs_url: '$(yq eval '.harvester_rootfs_url' "$settings_file")'"
	log_info
}

releases()
{
	local releases_url=https://api.github.com/repos/harvester/harvester/releases
	curl --silent "$releases_url" | jq '.[].tag_name' | tr --delete '"'
}

up()
{
	local ipxe_example_repo=https://github.com/harvester/ipxe-examples.git

	local launch_usage="Usage: $(dirname "$0") up [-lh] [-d <artifact-dir>] [-r <release-version>]

	args:
		-h                      show this help text
		-d <artifact_dir>       the directory to look in for harvester artifacts
		-r <release-version>    specify a specific release to use
		-g <repo>               the url to the repository to clone if no ipxe-examples found [$ipxe_example_repo]

	Note: if both -d and -r are specified only -d will be used.
	"

	local ipxe_start_script="$ipxe_dir/vagrant-pxe-harvester/setup_harvester.sh"
	local settings_file="$ipxe_dir/vagrant-pxe-harvester/settings.yml"

	while [ $# -gt 0 ]; do
		case "$1" in
			-h)
				echo "$launch_usage"
				exit
				;;
			-d)
				local artifacts_dir="$(realpath "$2")"
				shift
				;;
			-r)
				local release_version="$2"

				if ! releases | grep --quiet "$release_version"; then
					echo "could not find the harvester release '$release_version'"
					echo "run '$(basename "$0") -l' to get a list of harvester releases"
				fi

				shift
				;;
			-g)
				ipxe_example_repo="$2"
				shift
				;;
			*)
				echo "unrecognized argument '$1'"
				echo "$usage"
				exit 1
				;;
		esac

		shift
	done

	if [ ! -e "$ipxe_dir" ]; then
		log_info "could not find ipxe-examples at '$ipxe_dir', cloning from '$ipxe_example_repo'"
		git clone "$ipxe_example_repo" "$ipxe_dir"
		log_info
		log_info 'this would be a good time to configure your ipxe-example repo'
		log_info 'it would probably also be a good idea to change the ownership of the repo'
		log_info
	fi

	log_info "using ipxe-examples found at '$ipxe_dir'"
	log_info "settings file: $settings_file"

	if [ -n "$artifacts_dir" ]; then
		yq eval --inplace "(.harvester_iso_url = \"file://$artifacts_dir/harvester-master-amd64.iso\")
										 | (.harvester_kernel_url = \"file://$artifacts_dir/harvester-master-vmlinuz-amd64\")
										 | (.harvester_ramdisk_url = \"file://$artifacts_dir/harvester-master-initrd-amd64\")
										 | (.harvester_rootfs_url = \"file://$artifacts_dir/harvester-master-rootfs-amd64.squashfs\")" "$settings_file"
	elif [ -n "$release_version" ]; then
		release_base_url="https://releases.rancher.com/harvester/$release_version"
		yq eval --inplace "(.harvester_iso_url = \"$release_base_url/harvester-$release_version-amd64.iso\")
										 | (.harvester_kernel_url = \"$release_base_url/harvester-$release_version-vmlinuz-amd64\")
										 | (.harvester_ramdisk_url = \"$release_base_url/harvester-$release_version-initrd-amd64\")
										 | (.harvester_rootfs_url = \"$release_base_url/harvester-$release_version-rootfs-amd64.squashfs\")" "$settings_file"
	fi

	artifacts

	if [ "$(id -u)" -ne 0 ]; then
		log_error "up must be run as root"
		exit 1
	fi

	log_info 'starting harvester'
	if ! "$ipxe_start_script"; then
		log_error 'failed to launch harvester'
		log_info 'make sure your local ipxe example repo is compatible with the requested version of harvester'
		return
	fi

	password="$(yq eval '.harvester_config.password' "$settings_file")"
	host_ip="$(yq eval '.harvester_network_config.cluster[0].ip' "$settings_file")"

	log_info "removing '$host_ip' from known hosts"
	ssh-keygen -R "$host_ip" -f "$HOME/.ssh/known_hosts" > /dev/null 2>&1

	log_info "pulling kubeconfig from created cluster"
	sshpass -p "$password" ssh -o StrictHostKeyChecking=no "rancher@$host_ip" sudo chmod 644 /etc/rancher/rke2/rke2.yaml
	# todo: ideally we'd just merge this into a parent (kubectl config view --flatten)
	sshpass -p "$password" scp "rancher@$host_ip:/etc/rancher/rke2/rke2.yaml" "$HOME/.kube/config.harvester"
	yq eval --inplace ".clusters[0].cluster.server = \"https://$host_ip:6443\"" "$HOME/.kube/config.harvester"
}

down()
{
	if [ "$(id -u)" -ne 0 ]; then
		log_error "down must be run as root"
		exit 1
	fi

	local vagrant_dir="$ipxe_dir/vagrant-pxe-harvester"
	local vagrant_file="$vagrant_dir/Vagrantfile"

	if [ ! -e "$vagrant_file" ]; then
		log_info "could not find a Vagrantfile at '$vagrant_file', there is nothing to do"
		exit
	fi

	cd "$vagrant_dir" || exit 1

	log_info 'checking for running domains'
	local domains="$(vagrant status --machine-readable | grep state, | grep running | cut --delimiter , --fields 2)"

	if [ -z "$domains" ]; then
		log_info 'no running domains found, nothing to do'
		exit
	fi

	log_info "stopping domains: " $domains

	vagrant destroy --force $domains
}

if [ $# -eq 0 ]; then
	echo "expected a command but found none"
	echo "$usage"
	exit 1
fi

while [ $# -gt 0 ]; do
	case "$1" in
		-h)
			echo "$usage"
			exit
			;;
		-e)
			ipxe_dir="$2"
			shift
			;;
		up|down|releases|artifacts)
			command="$1"
			shift
			break
			;;
		*)
			echo "unrecognized argument '$1'"
			echo "$usage"
			exit 1
			;;
	esac

	shift
done

case "$command" in
	up)
		up $*
		;;
	down)
		down $*
		;;
	releases)
		releases $*
		;;
	artifacts)
		artifacts $*
		;;
esac
