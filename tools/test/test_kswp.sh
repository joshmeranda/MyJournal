#!/usr/bin/env dir
. "$(dirname "$0")/config"

test_image=joshmeranda/journaltest:latest
kswp_sh="$journal_tools_dir/kswp.sh"

test_kswp()
{
  container_id=$(docker run --detach \
    --mount type=bind,source="$kswp_sh",target=/kswp.sh \
    "$test_image")

  docker exec "$container_id" sh -c 'mkdir /root/.kube && echo local > /root/.kube/config.local && echo remote > /root/.kube/config.remote'

  docker exec "$container_id" /kswp.sh local
  assertEquals local "$(docker exec "$container_id" cat /root/.kube/config)"

  docker exec "$container_id" /kswp.sh remote
  assertEquals remote "$(docker exec "$container_id" cat /root/.kube/config)"

  docker container stop "$container_id" > /dev/null 2>&1
  docker container rm "$container_id" > /dev/null 2>&1
}
