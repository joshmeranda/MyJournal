#!/usr/bin/env sh

resources_dir="$(dirname "$0")/resources"
build_dir="$resources_dir/fish-build"
prefix_dir=/usr/bin

usage="Usage: $(basename "$0") [-h] [-b <build_dir>] [-p <prefix-dir>] <fish_version>

args:
  -h     display this help text
  -b     the directory to use for all build and installation files <$build_dir>
  -p     the directory to install fish into <$prefix_dir>
"

if [ "$#" -lt 1 ]; then
  echo 'expected a fish version but found none'
  echo "$usage"
fi

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h)
        echo "$usage"
        exit
        ;;
    -b)
        build_dir="$2"
        shift
        ;;
    -p)
      prefix_dir="$2"
      shift
      ;;
    *)
      if [ -z "$fish_version" ]; then
        version="$1"
      else
        echo "unexpected argument '$1'"
        echo "$usage"
        exit 1
      fi
  esac
  shift
done

if ! which cmake > /dev/null 2>&1; then
  log_error fish requires cmake for build, but it could not be found
  exit 2
fi

mkdir --parents "$build_dir"

if [ ! -e "$build_dir/fish-$version.tar.xz" ]; then
  fish_url="https://github.com/fish-shell/fish-shell/releases/download/$version/fish-$version.tar.xz"
  if ! wget --quiet --directory-prefix "$build_dir" "$fish_url"; then
    log_error "could not pull archive from '$fish_url'"
    exit 2
  fi
fi

cd "$build_dir" || exit 1

tar --extract --file "fish-$version.tar.xz"
cd "fish-$version" || exit 1

mkdir build && cd build

cmake -D CMAKE_INSTALL_PREFIX="$prefix_dir" -D BUILD_DOCS=OFF ..
make
make install
