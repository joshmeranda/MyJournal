#!/usr/bin/env bash
# Utility to let you use another machine a proxy to push docker images via ssh. Originally written to get around local
# issues with docker not being able to push to remote repos with the error:
#     denied: requested access to the resource is denied.

source "$(dirname $0)/logger.sh"

usage="Usage: $(basename $0) [opts] <ssh-host> [<image>...|<filter>...]

opts:
	-h --help     	        show this help text
	-i --images   	        treat arguments as image names (default)
	-f --filters  	        treat arguments as filters
	-d --directory <path>   destination to scp the saved image archive to
	   --image-file <path>  path to save the images to
	-n --no-confirm         do not ask for confirmation before saving and pushing images

Images without a tag will never be matched
"

found_tags=()

images_with_refs() {
	log_info 'checking provided image references'

	for ref in "$@"; do
		tags=($(docker image ls --format '{{.Repository}}:{{.Tag}}' "$ref" 2> /dev/null | grep --invert-match "^.*:<none>$"))

		if [ ${#tags[@]} -eq 0 ]; then
			log_error "could not find image for reference '$ref'"
		else
			log_debug "found image(s) '${tags[*]}' for reference '$ref'"
			found_tags+=("${found_tags[@]}" "${tags[@]}")
		fi
	done
}

images_with_filters() {
	log_info 'checking provided image filters'

	for filter in "$@"; do
		tags=($(docker image ls --format '{{.Repository}}:{{.Tag}}' --filter "$filter" 2> /dev/null | grep --invert-match "^.*:<none>$"))

		if [ ${#tags[@]} -eq 0 ]; then
			log_error "could not find image for filter '$filter'"
		else
			log_debug "found image(s) '${tags[*]}' for filter '$filter'"
			found_tags+=("${found_tags[@]}" "${tags[@]}")
		fi
	done
}

images=true
filters=false
confirm=true

while [ $# -gt 0 ]; do
	case "$1" in
		-h | --help)
			echo "$usage"
			exit
			;;
		-i | --images)
			images=true
			;;
		-f | --filters)
			filters=true
			images=false
			;;
		-d | --destination)
			scp_destination="$1"
			;;
		--image-file)
			image_file="$1"
			;;
		-n | --no-confirm)
			confirm=false
			;;
		*)
			break
			;;
	esac
	shift
done

case $# in
	0)
		printf 'expected an ssh host but found none\n%s' "$usage"
		exit 1
		;;
	1)
		printf "expected at least 1 image name or filter but found none\n%s" "$usage"
		exit 1
		;;
esac

ssh_host="$1"
shift

ssh_user="$(cut --delimiter @ --fields 1 <<< "$ssh_host")"
if [ -z "$scp_destination" ]; then
	scp_destination="/home/$ssh_user/image.tar.gz"
fi

if $images; then
	images_with_refs "$@"
elif $filters; then
	images_with_filters "$@"
else
	printf "bug: either filters or images must be true"
	exit 2
fi

if [ ${#found_tags[@]} -eq 0 ]; then
	log_error 'found no tags for provided options'
	exit
fi

if [ -z "$image_file" ]; then
	image_file="$(mktemp)"
fi

ssh_cmd="docker load --input $scp_destination"

log_info "found ${#found_tags[@]} tag(s):"
for tag in "${found_tags[@]}"; do
	log_info "    $tag"
	ssh_cmd="$ssh_cmd && docker push $tag"
done

if $confirm; then
	read -p "continue? [Y/n]" continue

	if [[ ! "$continue" =~ y|Y ]] && [ -n "$continue" ]; then
		echo "continue: '$continue'"
		exit
	fi
fi

log_debug "saving image to '$image_file'"
docker save --output "$image_file" "${found_tags[@]}"

log_info "sending images to '$ssh_host'"
scp "$image_file" "$ssh_host:$scp_destination"

log_info "importing and pushing images"
log_debug "ssh command: $ssh_cmd"
ssh "$ssh_host" <<< "$ssh_cmd"
