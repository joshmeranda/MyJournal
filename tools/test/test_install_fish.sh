#!/usr/bin/env dir
. "$(dirname "$0")/config"

test_image=joshmeranda/journaltest:latest
fish_install="$journal_dir/shells/fish/tools/install_fish.sh"
logger_sh="$journal_tools_dir/logger.sh"

fish_version=3.5.1

test_install_fish()
{
  container_id=$(docker run --detach \
    --mount type=bind,source="$fish_install",target=/root/tools/install_fish.sh \
    --mount type=bind,source="$logger_sh",target=/root/tools/logger.sh \
    "$test_image")

  docker exec "$container_id" /root/tools/install_fish.sh $fish_version > /dev/null 2>&1

  assertEquals /usr/local/bin/fish "$(docker exec "$container_id" which fish)"
  assertEquals /usr/local/bin/fish_indent "$(docker exec "$container_id" which fish_indent)"
  assertContains /usr/local/bin/fish "$(docker exec "$container_id" cat /etc/shells)"

  docker container stop "$container_id" > /dev/null 2>&1
  docker container rm "$container_id" > /dev/null 2>&1
}