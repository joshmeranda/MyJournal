#!/usr/bin/env sh
test_image=joshmeranda/journaltest:latest

. "$(dirname "$0")/config"

config_sh="$journal_dir/tools/config.sh"
original_dir="$(pwd)"
archive="$journal_dir/myjournal.tar.gz"

# check the hash of a host file against the has of a file on a container
# $1: container id
# $2: host file path
# $3: container file path
assert_hashes()
{
  assertEquals \
    "$(md5sum "$2" | cut --delimiter ' ' --fields 1)" \
    "$(docker exec "$1" md5sum "$3" | cut --delimiter ' ' --fields 1)"
}

# check the hash of a host file against the has of a file on a container
# $1: container id
# $2: host file path
# $3: container file path
assert_not_hashes()
{
  assertNotEquals \
    "$(md5sum "$2" | cut --delimiter ' ' --fields 1)" \
    "$(docker exec "$1" md5sum "$3" | cut --delimiter ' ' --fields 1)"
}

# test callbacks
setUp()
{
  cd "$journal_dir" || exit 1
}

tearDown()
{
  rm --force "$archive"
}

tearDownOnce()
{
  cd "$original_dir" || exit 2
}

# tests
test_config_package_all()
{
  "$config_sh" with-all > /dev/null 2>&1

  archived_files="$(tar --list --file "$archive")"

  assertContains "$archived_files" .bashrc
  assertContains "$archived_files" config.fish
  assertContains "$archived_files" config.json
  assertContains "$archived_files" install.sh
  assertContains "$archived_files" tools/docker-login.sh
  assertContains "$archived_files" tools/cp-harv-iso.bash
  assertContains "$archived_files" tools/get-harv-config.bash
  assertContains "$archived_files" tools/launch-harvester.bash
  assertContains "$archived_files" tools/logger.sh
  assertContains "$archived_files" tools/reset-harvester.bash
  assertContains "$archived_files" tools/run-script.bash
  assertContains "$archived_files" tools/setup-scripts/harv.bash
  assertContains "$archived_files" tools/teardown-harvester.bash
}

test_config_package_with_only_bash_fish()
{
  "$config_sh" with-fish with-bash > /dev/null 2>&1

  archived_files="$(tar --list --file "$archive")"

  assertContains "$archived_files" .bashrc
  assertContains "$archived_files" config.fish
  assertContains "$archived_files" config.json
  assertContains "$archived_files" install.sh

  assertNotContains "$archived_files" tools/docker-login.sh
  assertNotContains "$archived_files" tools/cp-harv-iso.bash
  assertNotContains "$archived_files" tools/get-harv-config.bash
  assertNotContains "$archived_files" tools/launch-harvester.bash
  assertNotContains "$archived_files" tools/logger.sh
  assertNotContains "$archived_files" tools/reset-harvester.bash
  assertNotContains "$archived_files" tools/run-script.bash
  assertNotContains "$archived_files" tools/setup-scripts/harv.bash
  assertNotContains "$archived_files" tools/teardown-harvester.bash
}

test_config_install()
{
  "$config_sh" with-all > /dev/null 2>&1

  container_id=$(docker run --detach --mount type=bind,source="$archive",target=/myjournal.tar.gz "$test_image")

  docker exec "$container_id" tar --extract --file /myjournal.tar.gz > /dev/null 2>&1
  docker exec "$container_id" /myjournal-config/install.sh > /dev/null 2>&1

  # shell configurations
  assert_hashes "$container_id" "$journal_dir/shells/bash/config/.bashrc" /root/.bashrc
  assert_hashes "$container_id" "$journal_dir/shells/fish/config/config.fish" /root/.config/fish/config.fish

  # docker tools
  assert_hashes "$container_id" "$journal_dir/docker/tools/docker-login.sh" /root/tools/docker-login.sh

  # harvester tools
  assert_hashes "$container_id" "$journal_dir/harvester/tools/cp-harv-iso.bash" /root/tools/cp-harv-iso.bash
  assert_hashes "$container_id" "$journal_dir/harvester/tools/get-harv-config.bash" /root/tools/get-harv-config.bash
  assert_hashes "$container_id" "$journal_dir/harvester/tools/launch-harvester.bash" /root/tools/launch-harvester.bash
  assert_hashes "$container_id" "$journal_dir/harvester/tools/reset-harvester.bash" /root/tools/reset-harvester.bash
  assert_hashes "$container_id" "$journal_dir/harvester/tools/teardown-harvester.bash" /root/tools/teardown-harvester.bash
  assert_hashes "$container_id" "$journal_dir/harvester/tools/run-script.bash" /root/tools/run-script.bash
  assert_hashes "$container_id" "$journal_dir/harvester/tools/setup-scripts/harv.bash" /root/tools/setup-scripts/harv.bash

  # other tools
  assert_hashes "$container_id" "$journal_dir/tools/logger.sh" /root/tools/logger.sh

  docker container stop "$container_id" > /dev/null 2>&1
  docker container rm "$container_id" > /dev/null 2>&1
}

test_config_install_overwrite()
{
  "$config_sh" with-bash with-fish > /dev/null 2>&1

  container_id=$(docker run --detach --mount type=bind,source="$archive",target=/myjournal.tar.gz "$test_image")

  docker exec "$container_id" tar --extract --file /myjournal.tar.gz > /dev/null 2>&1
  docker exec "$container_id" sh -c 'touch $HOME/.bashrc \
    && mkdir  --parents $HOME/.config/fish \
    && echo "echo hello world" > $HOME/.config/fish/config.fish \
    && echo "echo another hello world" > $HOME/.config/fish/another_config.fish'
  docker exec "$container_id" /myjournal-config/install.sh -o > /dev/null 2>&1

  # shell configurations
  assert_hashes "$container_id" "$journal_dir/shells/bash/config/.bashrc" /root/.bashrc
  assert_hashes "$container_id" "$journal_dir/shells/fish/config/config.fish" /root/.config/fish/config.fish

  assertEquals 'echo another hello world' "$(docker exec "$container_id" cat /root/.config/fish/another_config.fish)"

  docker container stop "$container_id" > /dev/null 2>&1
  docker container rm "$container_id" > /dev/null 2>&1
}

test_config_install_no_overwrite()
{
  "$config_sh" with-bash with-fish > /dev/null 2>&1

  container_id=$(docker run --detach --mount type=bind,source="$archive",target=/myjournal.tar.gz "$test_image")

  docker exec "$container_id" tar --extract --file /myjournal.tar.gz > /dev/null 2>&1
  docker exec "$container_id" sh -c 'touch $HOME/.bashrc \
    && mkdir  --parents $HOME/.config/fish \
    && echo "echo hello world" > $HOME/.config/fish/config.fish \
    && echo "echo another hello world" > $HOME/.config/fish/another_config.fish'
  docker exec "$container_id" /myjournal-config/install.sh > /dev/null 2>&1

  # shell configurations
  assert_not_hashes "$container_id" "$journal_dir/shells/bash/config/.bashrc" /root/.bashrc
  assert_not_hashes "$container_id" "$journal_dir/shells/fish/config/config.fish" /root/.config/fish/config.fish

  assertEquals 'echo another hello world' "$(docker exec "$container_id" cat /root/.config/fish/another_config.fish)"

  docker container stop "$container_id" > /dev/null 2>&1
  docker container rm "$container_id" > /dev/null 2>&1
}