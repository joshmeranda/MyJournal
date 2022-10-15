#!/usr/bin/env dir
. "$(dirname "$0")/config"

test_image=joshmeranda/journaltest:latest
kubectl_install="$journal_dir/kubernetes/tools/install_kubectl.sh"
logger_sh="$journal_tools_dir/logger.sh"

kubectl_version=v1.25.3

test_install_kubectl()
{
  container_id=$(docker run --detach \
    --mount type=bind,source="$kubectl_install",target=/root/tools/install_kubectl.sh \
    --mount type=bind,source="$logger_sh",target=/root/tools/logger.sh \
    "$test_image")

  docker exec "$container_id" /root/tools/install_kubectl.sh -v "$kubectl_version" -d /opt/kubectl -i /usr/bin > /dev/null 2>&1

  if ! docker container exec "$container_id" test -L /usr/bin//kubectl; then
    fail 'expected a symlink at /usr/bin/kubectl'
  fi

  if ! docker container exec "$container_id" test -x /opt/kubectl/kubectl; then
    fail 'expected an executable file at /opt/kubectl/kubectl'
  fi

  assertEquals "$kubectl_version" "$(docker container exec "$container_id" kubectl version --client --output json | jq .clientVersion.gitVersion | tr --delete '"')"

  docker container stop "$container_id" > /dev/null 2>&1
  docker container rm "$container_id" > /dev/null 2>&1
}