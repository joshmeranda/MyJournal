#!/usr/bin/env sh
test_image=joshmeranda/journaltest:latest

. "$(dirname "$0")/config"

foff_sh="$journal_tools_dir/foff.sh"
logger_sh="$journal_tools_dir/logger.sh"

test_foff_kill_force()
{
  container_id=$(docker run --detach \
    --mount type=bind,source="$foff_sh",target=/foff.sh \
    --mount type=bind,source="$logger_sh",target=/logger.sh \
    "$test_image")

  # make script for running process
  docker exec "$container_id" bash -c 'echo sleep inf > sleeper.sh'

  docker exec --detach "$container_id" sh /sleeper.sh > /dev/null 2>&1
  docker exec --detach "$container_id" sh /sleeper.sh > /dev/null 2>&1

  docker exec "$container_id" /foff.sh -f sleeper.sh > /dev/null 2>&1

  assertEquals 0 "$(docker exec "$container_id" pgrep --count --full sleeper.sh)"

  docker container stop "$container_id" > /dev/null 2>&1
  docker container rm "$container_id" > /dev/null 2>&1
}