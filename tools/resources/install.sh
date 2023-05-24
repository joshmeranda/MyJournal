#!/usr/bin/env bash
# this script is intended to install the configurations and tools packaged in
# config.sh

export LOG_LEVEL_CRITICAL=10 \
       LOG_LEVEL_ERROR=20 \
       LOG_LEVEL_WARNING=30 \
       LOG_LEVEL_INFO=40 \
       LOG_LEVEL_DEBUG=50

LOG_LEVEL_DEFAULT=$LOG_LEVEL_INFO

# Allows user to specify their own default log level by exporting a value for
# LOG_LEVEL before sourcing this script
LOG_LEVEL=${LOG_LEVEL:-$LOG_LEVEL_DEFAULT}

prefix()
{
  level="$1"
  timestamp="$(date --iso-8601=seconds)"

  echo "$timestamp [$level]"
}

write_log()
{
  prefix="$(prefix $1)"
  shift

  echo "$prefix $*"
}

should_log()
{
  test "$1" -le "$LOG_LEVEL"
}

log_critical()
{
    should_log $LOG_LEVEL_CRITICAL && write_log critical "$@"
}

log_error()
{
    should_log $LOG_LEVEL_ERROR && write_log error "$@"
}

log_warning()
{
    should_log $LOG_LEVEL_WARNING && write_log warning "$@"
}

log_info()
{
    should_log $LOG_LEVEL_INFO && write_log info "$@"
}

log_debug()
{
    should_log $LOG_LEVEL_DEBUG && write_log debug "$@"
}

usage="Usage: $(basename $0) [-ho] [-f config] <archive>

args:
  -h            display this help text
  -o            overwrite files if they already exists
  -f <config>   merge the given file into the archive's config.json overwriting
                any conflicting values
"

config_dir="$(pwd)"
config_file="$config_dir/config.yaml"

overwrite=false

TOOLS="$HOME/tools"
INSTALLERS="$TOOLS/installers"

# install the target ($1) to the destination ($2)
#
install_target()
{
  target="$1"
  target_path="$config_dir/$1"

  destination="$(eval echo "$2")"

  if [ "${destination: -1}" == / ]; then
    destination="$destination/$(basename $target)"
  fi

  if [ ! -e "$target_path" ]; then
    log_error "no such path '$target_path' exists, skipping target '$target'"
    return 1
  fi

  log_info "installing target '$target' to '$destination'"

  # we only care about overwriting if it is a file, since directories can be "safely" merged
  if [ -e "$destination" ] && [ -f "$destination" ]; then
    if ! $overwrite; then
      log_info "destination '$destination' already exists, skipping target '$target'"
      return 1
    fi
  fi

  target_parent="$(dirname $destination)"

  if [ ! -e "$target_parent" ]; then
    mkdir --parents "$target_parent"
  fi

  cp $cp_flags "$target_path" "$destination"
}

while [ $# -gt 0 ]; do
  case "$1" in
    -h)
      echo "$usage"
      exit
      ;;
    -o)
      overwrite=true
      ;;
    *)
      archive="$1"
      break
      ;;
  esac

  shift
done

if $overwrite; then
  cp_flags='--recursive'
else
  cp_flags='--recursive  --no-clobber'
fi

readarray configs < <(yq eval --output-format json --indent 0 '.configs[]' "$config_file")
readarray tools < <(yq eval --output-format json --indent 0 '.tools[]' "$config_file")

for config in "${configs[@]}"; do
  install_target "configs/$(echo $config | yq eval '.path' -)" "$(echo $config | yq eval '.install' -)"
done

for tool in "${tools[@]}"; do
  install_target "tools/$(echo $tool | yq eval '.path' -)" "$(echo $tool | yq eval '.install' -)"
done