#!/usr/bin/env sh
test_image=joshmeranda/journaltest:latest

journal_dir="$(realpath ../../)"
docker_login="$journal_dir/docker/tools/docker-login.sh"

test_docker_login()
{
  container_id=$(docker run --detach --mount type=bind,source="$docker_login",target=/docker-login.sh "$test_image")

  # verify that user add works
  docker exec "$container_id" /docker-login.sh add gandalf some-token > /dev/null 2>&1
  assertEquals "$(echo some-token | base64)" "$(docker exec "$container_id" cat /root/.local/docker-login/gandalf.token)"

  # verify that we cannot re-add the same user
  out="$(docker exec "$container_id" /docker-login.sh add gandalf some-token 2>&1)"
  assertEquals "file already exists for user 'gandalf'" "$out"
  assertEquals "$(echo some-token | base64)" "$(docker exec "$container_id" cat /root/.local/docker-login/gandalf.token)"

  # verify removing user works as expected
  docker exec "$container_id" /docker-login.sh remove gandalf

  if docker exec "$container_id" test -f /root/.local/doker-login/gandalf.token; then
    docker exec --interactive --tty "$container_id" sh
    fail "file '/root/.local/docker-login/gandalf.token' should not exist"
  fi

  docker container stop "$container_id" > /dev/null 2>&1
  docker container rm "$container_id" > /dev/null 2>&1
}