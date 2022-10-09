#!/usr/bin/env sh
test_image=joshmeranda/journaltest:latest

. "$(dirname "$0")/config"

wf_sh="$journal_tools_dir/wf.sh"
failer_sh="$journal_test_resource_dir/failer.sh"

test_wf_no_limit()
{
  container_id=$(docker run --detach \
    --mount type=bind,source="$wf_sh",target=/wf.sh \
    --mount type=bind,source="$failer_sh",target=/failer.sh \
    "$test_image")

  docker exec "$container_id" bash -c 'echo 3 > /fails_left'

  out="$(timeout 4 docker exec "$container_id" /wf.sh /failer.sh)"
  return_code="$?"

  # check if return code indicates that timeout exited (code 124) or if command exited (anything else)
  if [ "$return_code" -eq 124 ]; then
    fail 'wf.sh did not exit as soon as expected'
  fi

  assertEquals ...ok "$(echo "$out" | head --lines 1)"
  assertEquals DONE "$(echo "$out" | tail --lines +2)"

  docker container stop "$container_id" > /dev/null 2>&1
  docker container rm "$container_id" > /dev/null 2>&1
}

test_wf_no_limit_quiet()
{
  container_id=$(docker run --detach \
    --mount type=bind,source="$wf_sh",target=/wf.sh \
    --mount type=bind,source="$failer_sh",target=/failer.sh \
    "$test_image")

  docker exec "$container_id" bash -c 'echo 3 > /fails_left'

  out="$(timeout 4 docker exec "$container_id" /wf.sh -q /failer.sh)"
  return_code="$?"

  # check if return code indicates that timeout exited (code 124) or if command exited (anything else)
  if [ "$return_code" -eq 124 ]; then
    fail 'wf.sh did not exit as soon as expected'
  fi

  assertEquals DONE "$(echo "$out" | head --lines 1)"

  docker container stop "$container_id" > /dev/null 2>&1
  docker container rm "$container_id" > /dev/null 2>&1
}

test_wf_no_limit_silent()
{
  container_id=$(docker run --detach \
    --mount type=bind,source="$wf_sh",target=/wf.sh \
    --mount type=bind,source="$failer_sh",target=/failer.sh \
    "$test_image")

  docker exec "$container_id" bash -c 'echo 3 > /fails_left'

  out="$(timeout 4 docker exec "$container_id" /wf.sh -s /failer.sh)"
  return_code="$?"

  if [ "$return_code" -ne 0 ]; then
    fail 'wf.sh did not exit as soon as expected'
  fi

  assertEquals '' "$out"

  docker container stop "$container_id" > /dev/null 2>&1
  docker container rm "$container_id" > /dev/null 2>&1
}

test_wf_exceed_limit()
{
  container_id=$(docker run --detach \
    --mount type=bind,source="$wf_sh",target=/wf.sh \
    --mount type=bind,source="$failer_sh",target=/failer.sh \
    "$test_image")

  docker exec "$container_id" bash -c 'echo 3 > /fails_left'

  out="$(timeout 3 docker exec "$container_id" /wf.sh -m 2 /failer.sh)"
  return_code="$?"

  # check if return code indicates that timeout exited (code 124) or if command exited (anything else)
  if [ "$return_code" -eq 124 ]; then
    fail 'wf.sh did not exit as soon as expected'
  fi

  assertEquals ..err "$(echo "$out" | head --lines 1)"
  assertEquals '' "$(echo "$out" | tail --lines +2)"

  docker container stop "$container_id" > /dev/null 2>&1
  docker container rm "$container_id" > /dev/null 2>&1
}
