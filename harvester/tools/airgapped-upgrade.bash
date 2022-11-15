#!/usr/bin/env bash
# setup the infrastructure for an airgapped upgrade

image=halverneus/static-file-server:v1.8.8
port=8080
docker_flags=()
host=localhost
release_date=$(date '+%Y%m%d')
version_name="dev"

usage="Usage: $(basename "$0") <iso>

args:
  -h,--help                show this help text
  -p,--port N              the port to expose for serving http requests [$port]
  -d,--detach              run the server in the background
     --host HOST           the ip for the iso server [$host]
  -r,--release-date DATE   the iso release date [$release_date]
  -n,--name NAME           the name for the version [$version_name]
"

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h | --help)
      echo "$usage"
      ;;
    -p | --port)
      port="$2"
      shift

      if (( "$port" < 1 || "$port" > 65535 )); then
        echo "'$port' is not a valid port number"
        exit 1
      fi
      ;;
    -d | --detach)
      docker_flags=(--detach)
      ;;
    --host)
      host="$2"
      shift
      ;;
    -r | --release-date)
      release_date="$2"
      shift
      ;;
    -n | --name)
      version_name="$2"
      shift
      ;;
    *)
      iso="$(realpath "$1")"
      remote_iso="/web/$(basename "$1")"
      shift

      break
  esac

  shift
done

if [ -z "$iso" ]; then
  echo "expected path to iso but found none"
  exit 1
fi

docker_flags+=(--mount "type=bind,source=$iso,target=$remote_iso"
               --publish "$port:8080")

if [ "$#" -gt 0 ]; then
  echo "unexpected argument '$1'"
  exit 1
fi

echo "getting checksum for iso file '$iso'"
checksum="$(sha512sum "$iso" | cut --delimiter ' ' --field 1)"

echo 'applying version'
cat <<EOF | kubectl apply --filename -
apiVersion: harvesterhci.io/v1beta1
kind: Version
metadata:
  name: $version_name
  namespace: harvester-system
spec:
  isoChecksum: '$checksum'
  isoURL: https://$host/$(basename "$iso")
  releaseDate: '$release_date'
EOF

echo "launching server with image '$image'"
echo "listening on port '$port'"
if ! docker run "${docker_flags[@]}" "$image"; then
  echo "server shutdown"
  exit 1
fi
