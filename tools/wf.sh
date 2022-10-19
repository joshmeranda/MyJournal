#!/usr/bin/env sh

# todo: it would be nice to have more control over output
#   dots and output
#   dots and no output
#   no dots and output
#   no dots and no output

usage="Usage: $(basename "$0") [-hq] [-m <max-attempts>] [-i <interval>] <args>...

opts:
  -m           maximum count amount [inf]
  -i           the interval between attempts [1]
  -q           show no output at failed attempt, but still show the output for
               the last attempt
  -s           show no output at all (overrides -q)
"

if [ "$#" -eq 0 ]; then
  echo "expected a command but found none"
  echo "$usage"
  exit 1
fi

assert_positive_int()
{
  case "$1" in
    *[!0-9]*|'')
      echo "value '$1' is not a valid positive"
      exit 1
      ;;
  esac
}

max_attempts=-1
interval=1
quiet=false
silent=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h)
      echo "$usage"
      exit
      ;;
    -m)
      assert_positive_int "$2"
      max_attempts=$2
      shift
      ;;
    -i)
      assert_positive_int "$2"
      interval=$2
      shift
      ;;
    -q)
      quiet=true
      ;;
    -s)
      silent=true
      ;;
    *)
      args="$*"
      break
      ;;
  esac
  shift
done

if $silent && $quiet; then
  quiet=false
fi

cmd_out="$(mktemp --suffix .wf)"
attempts=0

while ! $args > "$cmd_out" 2>&1 && { [ "$max_attempts" = -1 ] || [ "$attempts" -lt "$max_attempts" ]; }; do
  attempts=$((attempts + 1))

  if ! $silent && ! $quiet; then
    printf .
  fi

  sleep "$interval"
done

if ! $silent && ! $quiet; then
  if [ "$attempts" -eq "$max_attempts" ]; then
    echo err
  else
    echo ok
  fi
fi


if ! $silent; then
  cat "$cmd_out"
fi

if [ "$attempts" -eq "$max_attempts" ]; then
  exit 1
fi
