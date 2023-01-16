#!/usr/bin/env sh

. "$(dirname "$0")/logger.sh"

version=$(curl -L -s https://dl.k8s.io/release/stable.txt)
download_dir="$HOME/.local/bin"
install_dir="$download_dir"

usage="Usage: $(basename "$0") [-h] [-v <kubectl-version>] [-d <download-dir>] [-i <install-dir>]

args:
	-h                     display this help text
	-v <version>           the version of kubectl to install [$version]
	-d <download-dir>      the directory to download the kubectl binary to [$download_dir]
	-i <install-dir>       if different from the download location, a symlink to
												 the downloaded file will be created in this directory [$install_dir]
"

while [ "$#" -gt 0 ]; do
	case "$1" in
		-h)
			echo "$usage"
			exit
			;;
		-v)
			version="$2"
			shift
			;;
		-d)
			download_dir="$2"
			shift
			;;
		-i)
			install_dir="$2"
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

download_url="https://dl.k8s.io/release/$version/bin/linux/amd64/kubectl"
checksum_url="https://dl.k8s.io/$version/bin/linux/amd64/kubectl.sha256"

if [ -e "$download_dir/kubectl" ]; then
	log_info "using existing kubectl download at '$download_dir/kubectl'"
else
	log_info "fetching kubectl from '$download_url'"
	mkdir --parents "$download_dir"

	if ! curl --silent --location --output "$download_dir/kubectl" "$download_url"; then
		log_error 'could not fetch kubectl'
		exit 1
	fi

	log_info "validating checksum from '$checksum_url'"
	if ! curl --silent --location --output "$download_dir/kubectl.sha256" "$checksum_url"; then
		log_error 'could not fetch kubectl checksum'
		exit 1
	fi

	echo "$(cat "$download_dir/kubectl.sha256")" $download_dir/kubectl | sha256sum --status --check
	if ! echo "$(cat "$download_dir/kubectl.sha256")" $download_dir/kubectl | sha256sum --status --check; then
		log_error "checksum file '$download_dir/kubectl.sha256' does not match"
		exit 1
	fi
fi

if [ ! -x "$download_dir/kubectl" ]; then
	log_info "granting execute permissions to '$download_dir/kubectl'"
	chmod +x "$download_dir/kubectl"
fi

if [ "$download_dir" != "$install_dir" ]; then
	log_info "creating symlink to kubectl in '$install_dir'"
	if ! ln --symbolic "$download_dir/kubectl" "$install_dir"; then
		exit 1
	fi
fi
