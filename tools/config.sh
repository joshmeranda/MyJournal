#!/usr/bin/env sh
# this script is intended to collect any configuration files or commands for a nicely configured system

source "$(dirname $0)/logger.sh"

journal_root="$(dirname $(dirname "$0"))"
resource_dir="$(dirname "$0")/resources"

usage="Usage: $(basename "$0") [-f config ] [-h] [opts...]

args:
	config                the path to a file pairing configuration target to an
												installation directory

opts:
	with-all              include all scripts and configurations
	with-bash             include bash scripts / configurations
	with-docker           include docker scripts / configurations
	with-elasticsearch    include elasticsearch scripts / configurations
	with-harvester        include harvester scripts / configurations
	with-fish             include fish scripts / configurations
	with-kubernetes       include kubernetes scripts / configurations
	with-rancher          include rancher scripts / configurations
	with-tools            include tools scripts / configurations

if a opt includes tools of its own, they will be included and installed as any
of the tools would be. For example, if with-docker is enabled, after the
configuration archive is applied, the docker_login.bash script will be created
at $HOME/tools
"

temp_dir="$(mktemp --directory)"
config_dir="$temp_dir/myjournal-config"
tools_dir="$config_dir/tools"
config_file="$config_dir/config.json"

config_json='{}'

with_all=false
with_bash=false
with_docker=false
with_elasticsearch=false
with_harvester=false
with_fish=false
with_kubernetes=false
with_rancher=false
with_tools=false

# add a target ($1) destination ($2) pair to $config_file json configuration if
# the destination already exists in the configuration the pre-existing value is
# used.
register_cfg()
{
	dest="$(echo "$config_json" | jq ".[\"$1\"]" | tr --delete '"')"

	if [ "$dest" != null ]; then
		log_debug "key '$1' already exists, using pre-existing value '$dest'"
	else
		config_json="$(echo "$config_json" | jq ". |= . + {\"$1\" : \"$2\"}")"
		log_debug "registered key '$1' -> '$2'"
	fi
}

package_bash()
{
	log_info packaging bash
	cp shells/bash/config/.bashrc "$config_dir"

	register_cfg .bashrc '$HOME/.bashrc'
}

# a generic function to package a journal topic with only tools given its path
# relative to the journal root
package_generic()
{
	topic_dir="$1"
	topic_tools_dir="$topic_dir/tools"

	log_info "packaging $(basename "$topic_dir")"

	if [ -d "$topic_tools_dir" ]; then
		if ! cp --recursive --dereference "$topic_tools_dir"/* "$tools_dir"; then
			log_error "error packaging $(basename "$topic_dir")"
		fi
	fi
}

package_fish()
{
	log_info packaging fish
	cp shells/fish/config/config.fish "$config_dir"
	cp shells/fish/tools/install_fish.sh "$tools_dir"

	register_cfg config.fish '$HOME/.config/fish/config.fish'
}

package_tools()
{
	log_info "packaging tools"

	cp tools/*.sh "$tools_dir"

	register_cfg tools '$HOME/tools'
}

# package all of configurations and tools from myjournal into a single tar
# archive.
#
# when copying symlinks, ALWAYS deference it to avoid broken links
package_targets()
{
	log_debug "tmp directory at '$config_dir'"

	# ensure this directory exists when package targets
	mkdir --parents "$tools_dir"

	cp "$resource_dir/install.sh" "$config_dir"

	if $with_all || $with_bash; then package_bash; else log_info skipping bash; fi
	if $with_all || $with_docker; then package_generic docker; else log_info skipping docker; fi
	if $with_all || $with_elasticsearch; then package_generic elasticsearch; else log_info skipping elasticsearch; fi
	if $with_all || $with_harvester; then package_generic harvester; else log_info skipping harvester; fi
	if $with_all || $with_fish; then package_fish; else log_info skipping fish; fi
	if $with_all || $with_kubernetes; then package_generic kubernetes; else log_info skipping kubernetes; fi
	if $with_all || $with_rancher; then package_generic rancher; else log_info skipping rancher; fi

	if $with_all || $with_tools; then
		package_tools
	else
		log_info skipping tools

		if [ -d "$tools_dir" ]; then
			register_cfg tools '$HOME/tools'
		fi
	fi

	tar_file="myjournal.tar.gz"

	echo "$config_json" | jq . > "$config_file"

	tar --create --gzip --file "$tar_file" --directory "$temp_dir" "$(basename "$config_dir")"

	log_info "packaged configs to archive '$tar_file'"
}

# load the given configuration file ($1)
load_config()
{
	if [ -n "$1" ]; then
	 log_debug "loading file at '$2'"

	 if [ ! -f "$1" ]; then
		 log_error "no such file '$2' exists, cannot continue"
		 exit 1
	 fi

	 if ! jq . "$1" >/dev/null 2>&1; then
		 log_error "file '$1' is not valid json, cannot continue"
		 exit 1
	 fi

	 config_json="$(jq . "$1")"
	fi
}

while [ $# -gt 0 ]; do
	case "$1" in
		-h)
			echo "$usage"
			exit 0
			;;
		-f)
			shift
			load_config "$1"
			;;
		with-*)
			name=$(echo "$1" | cut  --delimiter - --field 2)
			export "with_$name"=true
			;;
		*)
			log_error "unrecognized argument '$1'"
			exit 1
			;;
	esac
	shift
done

package_targets