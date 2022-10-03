#!/usr/bin/env sh

test_dir="$(dirname "$0")"
shunit="$test_dir/shunit2"

test_image=joshmeranda/journaltest:latest

. "$test_dir/../logger.sh"

#all_targets="$(find "$test_dir" -maxdepth 1 -executable -type f -name 'test_*.sh' \
all_targets="$(find "$test_dir" -maxdepth 1 -type f -name 'test_*.sh' \
              | cut --delimiter _ --field 2 \
              | cut --delimiter . --field 1)"

usage="Usage: $(basename $0) [-h --help] [targets...]

If no targets are specified, it will be assumed that you want to test all
targets. Run tests on tools in myjournal. To add a new target add a new file
called 'test_<target_name>.sh' in the same directory as this file.

targets:
$(echo "$all_targets" | sed 's/^/  /')
"

ensure_shunit2()
{
  . "$test_dir/config"

  if [ ! -e "$shunit" ]; then
    log_info "shunit not found locally, pulling from '$shunit_url'"

    archive="$(mktemp --suffix .myjournal)"

    if ! wget --quiet --output-document "$archive" "$shunit_url"; then
      log_error "could not pull shunit from '$shunit_url'"
    fi

    tar --strip-components 1 --extract --file "$archive" "shunit2-$shunit_version/shunit2"
  fi
}

ensure_docker()
{
  if [ -z "$(docker image ls --quiet --filter reference="$test_image")" ]; then
    log_info "test image '$test_image' not found, building"

    docker build --quiet --tag "$test_image" --file "$test_dir/Dockerfile" . > /dev/null
  fi
}

targets=""

while [ $# -gt 0 ]; do
  case "$1" in
    -h | --help)
      echo "$usage"
      exit 1
      ;;
    *)
      if [ -z "$targets" ]; then
        targets="$1"
      else
        targets="$targets:$1"
      fi

      if [ ! -e "$test_dir/test_$1.sh" ]; then
        log_error "no such target '$1' found"
        exit 1
      fi
      ;;
  esac

  shift
done

ensure_shunit2
ensure_docker

if [ -z "$targets" ]; then
  for target in $all_targets; do
    log_info "running test(s) for target '$target'"
    "$test_dir/shunit2" "$test_dir/test_$target.sh"
  done
else
  IFS=:
  for target in $targets; do
    log_info "running test(s) for target '$target'"
  done
fi
