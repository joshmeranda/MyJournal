#!/usr/bin/env sh

. "$(dirname "$0")/logger.sh"

usage="Usage: $(basename "$0") [-hf] [-s <signal>] <pattern>

opts:
  -h          show this help text
  -f          do not as for confirmation from user before killing processes
  -s          the signal to send to the found processes instead of SIGTERM you
              can get a list of supported signals with 'kill -l'
"

if [ "$#" -lt 0 ]; then
  echo "expected a process pattern but found none"
  echo "$usage"
  exit 1
fi

force=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h)
      echo "$usage"
      exit
      ;;
    -f)
      force=true
      ;;
    -s)
      signal="$2"

      if ! kill --list "$signal" > /dev/null 2>&1; then
        echo "Error: signal '$signal' is not valid"
        exit 1
      fi

      kill_flags="--signal $signal"

      shift
      ;;
    *)
      if [ -n "$pattern" ]; then
        echo "unexpected argument '$1'"
        echo "$usage"
        exit 1
      else
        pattern="$1"
      fi
      ;;
  esac

  shift
done

processes="$(pgrep --full --list-full "$pattern")"

if [ -z "$processes" ]; then
  echo 'Error: no processes found, there is nothing to do'
  exit
else
  log_info "found $(echo "$processes" | wc --lines) matching processes"
  echo "$processes"
fi

while ! $force; do
  printf 'continue signalling the found processes? [y/N] '
  read -r answer

  case "$answer" in
    y | Y)
      break
      ;;
    n | N)
      exit
      ;;
    *)
      test -n "$answer" && printf "cannot understand '%s', " "$answer"
      ;;
  esac
done

processes="$(echo "$processes" | cut --delimiter ' ' --fields 1)"

# shellcheck disable=SC2086
log_info killing processes $processes

# shellcheck disable=SC2086
kill $kill_flags $processes

log_info 'done'