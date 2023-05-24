#!/usr/bin/env sh
# this script is intended to collect any configuration files or commands for a nicely configured system,
# intended to be run from the root of the myjournal repository.

source "$(dirname $0)/logger.sh"

journal_root="$(dirname $(dirname "$0"))"
resource_dir="$(dirname "$0")/resources"

topic_file="topic.yaml"

# discover available targets
for i in *; do
	if [ ! -d "$i" ] || [[ "$i" == @(template|hooks) ]]; then
		continue
	fi

	topics+=("$i")
	export "with_$topic"=false
done

with_all=false
with_tools=false

# todo: add without-<topic>
usage="Usage: $(basename "$0") [-f config ] [-h] [opts...]

args:
	config    the path to a file pairing configuration target to installation directory
	list            list all available topics

opts:
	with-all              include all scripts and configurations
	with-<topic>          include the given topic

if a opt includes tools of its own, they will be included and installed as any
of the tools would be. For example, if with-docker is enabled, after the
configuration archive is applied, the docker_login.bash script will be created
at $HOME/tools
"

temp_dir="$(mktemp --directory)"
staging_dir="$temp_dir/myjournal-config"
configs_dir="$staging_dir/configs"
tools_dir="$staging_dir/tools"
config_file="$staging_dir/config.yaml"

# todo: add without-<topic> to exclude a topic
for topic in "${topics[@]}"; do
	export "with_$topic"=false
done

register_topic() {
	topic="$1"

	if [ -f "$topic/$topic_file" ]; then
		log_debug "found topic file for '$topic'"

		# merge topic files into the main config file
		# todo: ideally we'd append the topic name to the start of tool paths
		yq eval-all --inplace '. as $item ireduce({}; . *+ $item)' "$config_file" "$topic/$topic_file"
	else
		log_debug "no topic file for '$topic'"

		if [ -d "$topic/tools" ]; then
			log_debug "found tools for '$topic'"

			for tool in "$topic/tools"/*; do
				if [ -f "$tool" ] && [ ! -L "$tool" ] ; then
					yq eval --inplace ".tools += [{\"path\": \"$tool\", \"install\": \"\$TOOLS\"}]" "$config_file"
				fi
			done
		fi
	fi
}

register_tools() {
	for tool in tools/*; do
		if [ -f "$tool" ] && [ ! -L "$tool" ] ; then
			yq eval --inplace ".tools += [{\"path\": \"$tool\", \"install\": \"\$TOOLS/\"}]" "$config_file"
		fi
	done
}

# package all of configurations and tools from myjournal into a single tar
# archive.
#
# when copying symlinks, ALWAYS deference it to avoid broken links
register_topics()
{
	log_debug "tmp directory at '$staging_dir'"

	yq eval --inplace ".createdAt = \"$(date)\"" "$config_file"

	cp "$resource_dir/install.sh" "$staging_dir"

	# package a generic topic, which is just a directory of files
	for topic in "${topics[@]}"; do
		if [ ! -d "$topic" ]; then
			continue
		fi

		with_topic="with_$topic"

		if ! $with_all && ! ${!with_topic}; then
			log_info "skippping topic '$topic'"
			continue
		fi

		log_info "registering topic '$topic'"

		register_topic "$topic"
	done
}

stage_configs() {
	log_info staging configs
	readarray -t configs < <(yq eval --output-format json --indent 0 '.configs[]' "$config_file")
	for config in "${configs[@]}"; do
		path="$(echo "$config" | yq '.path' -)"
		staged_path="$configs_dir/$path"

		log_debug "staging '$path' to '$staged_path'"

		mkdir --parents "$(dirname "$staged_path")"
		cp --dereference --recursive "$path" "$staged_path"
	done
}

stage_tools() {
	log_info staging tools

	readarray -t tools < <(yq eval --output-format json --indent 0 '.tools[]' "$config_file")
	for tool in "${tools[@]}"; do
		path="$(echo "$tool" | yq '.path' -)"
		staged_path="$tools_dir/$path"

		log_debug "staging '$path' to '$staged_path'"

		mkdir --parents "$(dirname "$staged_path")"
		cp --dereference --recursive "$path" "$staged_path"
	done
}

package() {
	log_info packaging

	# ensure this directory exists when packaging topics
	mkdir --parents "$tools_dir" "$configs_dir" "$(dirname "$config_file")"
	touch "$config_file"

	if $with_all || $with_tools; then
		register_tools
	fi
	register_topics

	stage_configs
	stage_tools

	tar_file="myjournal.tar.gz"

	log_info "creating archive '$tar_file'"
	tar --create --gzip --file "$tar_file" --directory "$temp_dir" "$(basename "$staging_dir")"
}

while [ $# -gt 0 ]; do
	case "$1" in
		-h)
			echo "$usage"
			exit 0
			;;
		with-*)
			# todo: check if the topic is valid
			name=$(echo "$1" | cut  --delimiter - --field 2)
			export "with_$name"=true
			;;
		*)
			if [ -z "$command" ]; then
				command="$1"
			else
				log_error "unrecognized argument '$1'"
				exit 1
			fi
			;;
	esac
	shift
done

case "$command" in
	list)
		# print all of the topics that can be packaged
		for topic in "${topics[@]}"; do
			echo "$topic"
		done
		;;
	package)
		package
		;;
	*)
		log_error "unrecognized command '$command'"
		exit 1
		;;
esac

cat "$config_file"