#!/usr/bin/env sh

. "$(dirname "$0")/logger.sh"

harvester_release=v1.1.0
ipxe_dir="ipxe-examples"
vagrant_dir="$ipxe_dir/vagrant-pxe-harvester"
settings_file="$vagrant_dir/settings.yml"
log_dir=logs

if [ ! -f "$settings_file" ]; then
	log_error "could not fine ipxe settings file at '$settings_file'"
	exit 1
fi

rm --recursive --force "$log_dir"
mkdir --parents "$log_dir"

password="$(yq eval '.harvester_config.password' "$settings_file")"
host_ip="$(yq eval '.harvester_network_config.cluster[0].ip' "$settings_file")"

log_info "password: $password"
log_info "host ip: $host_ip"

log_info "starting driver 2787 for Harvester $harvester_release"

check_harvester_up()
{
	harvester_status="$(cd "$ipxe_dir/vagrant-pxe-harvester" && sudo vagrant status --machine-readable harvester-node-0 | grep state, | cut --delimiter , --field 4)"

	if [ ! "$harvester_status" = running ]; then
		return 1
	fi
}

attempt=0
max_attempts=100
while [ "$attempt" -lt "$max_attempts" ]; do
	attempt=$((attempt + 1))
	log_info "Starting attempt #$attempt"

	log_info 'starting harvester'
	if ! sudo "$(dirname "$0")/harvester.bash" up -g https://github.com/joshmeranda/ipxe-examples.git -r "$harvester_release" > "$log_dir/launch-harvester.$attempt" 2>&1; then
		log_error "failed to start harvester view '$log_dir/launch-harvester.$attempt' for details"
		sudo "$(dirname "$0")/harvester.bash" down
		continue
	fi

	if ! check_harvester_up; then
		log_error 'failed starting harvester'
		continue
	else
		log_info 'harvester is up'
	fi

	log_info "removing '$host_ip' from ssh hosts file '$HOME/.ssh/known_hosts'"
	ssh-keygen -R "$host_ip" -f "/home/jmeranda/.ssh/known_hosts" > /dev/null 2>&1

	log_info "checking for unknown_pods"
	sshpass -p "$password" scp "$(dirname "$0")/check-pods.sh" "rancher@$host_ip:/home/rancher" > /dev/null 2>&1

	out="$(sshpass -p "$password" ssh "rancher@$host_ip" "/home/rancher/check-pods.sh")"

	if echo "$out" | grep --quiet "ERROR"; then
		echo "$out"
		exit 1
	fi

	unknown_pods="$(echo "$out" | grep "Unknown" | cut --delimiter : --fields 2)"

	if [ -n "$unknown_pods" ]; then
		log_info "Found pods in Unknown state:" $unkown_pods

		for pod in $unknown_pods; do
			sshpass -p "$password" scp "rancher@$host_ip:/home/rancher/$pod.logs" "$log_dir"
			sshpass -p "$password" scp "rancher@$host_ip:/home/rancher/$pod.yaml" "$log_dir"
		done

		break
	else
		log_info "no pods with unknown state found"
	fi

	log_info shutting down harvester
	sudo "$(dirname "$0")/harvester.bash" down >/dev/null 2>&1
done
