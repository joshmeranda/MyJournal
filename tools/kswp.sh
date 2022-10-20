#!/usr/bin/env sh

kubedir=$HOME/.kube

usage="Usage: $(dirname "$0") [-hl] [-d <kubedir>] [kubeconfig-name]

args:
  -h               show this help text
  -d <kubedir>     the directory where the kubeconfigs are stored [$kubedir]
  -l               list available kubeconfigs

If no kubeconfig name is given you will be able to select a kubeconfig with an
interactive menu.
"

list_kubeconfig()
{
  find "$kubedir" -name 'config.*' -exec basename '{}' \; | cut --delimiter . --fields 2
}

ask_kubeconfig()
{
  kubeconfigs="$(list_kubeconfig | cat --number)"
  printf 'which config should be used:\n%s\nenter kubeconfig number or exit> ' "$kubeconfigs"

  read answer

  if [ "$answer" = exit ]; then
    exit
  fi

  kubeconfig="$(echo "$kubeconfigs" | grep "$answer" | tr '\t' ' ' | cut --delimiter ' ' --fields 7)"
}

list=false

while [ $# -gt 0 ]; do
  case "$1" in
    -h)
      echo "$usage"
      exit 0
      ;;
    -l)
      list=true
      ;;
    -d)
      kubedir="$2"
      shift
      ;;
    *)
      if [ -z "$kubeconfig" ]; then
        kubeconfig="$1"
      else
        echo "unexpected argument '$1'"
        echo "$usage"
      fi
  esac

  shift
done

if [ ! -d "$kubedir" ]; then
  echo "no such kubedir '$kubedir'"
  echo 1
fi

if $list; then
  list_kubeconfig
else
  if [ -z "$kubeconfig" ]; then
    ask_kubeconfig
  fi

  kubeconfig_path="$kubedir/config.$kubeconfig"

  if [ ! -f "$kubeconfig_path" ]; then
    echo "no such kubeconfig '$kubeconfig_path'"
    exit 1
  fi

  ln --force --symbolic "$kubeconfig_path" "$kubedir/config"
fi
