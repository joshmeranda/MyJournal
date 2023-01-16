#!/usr/bin/env sh
test_image=joshmeranda/journaltest:latest

. "$(dirname "$0")/config"

docker_login="$journal_dir/docker/tools/docker-login.sh"

test_docker_login()
{
  container_id=$(docker run --detach --mount type=bind,source="$docker_login",target=/docker-login.sh "$test_image")

  # verify that user add works
  docker exec "$container_id" /docker-login.sh add gandalf mellon > /dev/null 2>&1
  assertEquals "$(echo mellon | base64)" "$(docker exec "$container_id" jq -r ".gandalf.token" /root/.docker-login.json)"

  # verify that we cannot re-add the same user
  out="$(docker exec "$container_id" /docker-login.sh add gandalf mellon 2>&1)"
  assertEquals "entry already exists for user 'gandalf'" "$out"
  assertEquals "$(echo mellon | base64)" "$(docker exec "$container_id" jq -r ".gandalf.token" /root/.docker-login.json)"

  # verify removing user works as expected
  docker exec "$container_id" /docker-login.sh remove gandalf
	assertEquals false "$(docker exec "$container_id" jq "has(\"gandalf\")" /root/.docker-login.json)"

  docker container stop "$container_id" > /dev/null 2>&1
  docker container rm "$container_id" > /dev/null 2>&1
}