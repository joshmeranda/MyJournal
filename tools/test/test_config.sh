#!/usr/bin/env sh
test_image=joshmeranda/journaltest:latest

. "$(dirname "$0")/config"

config_sh="$journal_tools_dir/config.sh"
original_dir="$(pwd)"
archive="$journal_dir/myjournal.tar.gz"

# check the hash of a host file against the has of a file on a container
# $1: container id
# $2: host file path
# $3: container file path
assert_hashes()
{
  assertEquals "hashes for '$(basename "$2")' are !=" \
    "$(md5sum "$2" | cut --delimiter ' ' --fields 1)"   \
    "$(docker exec "$1" md5sum "$3" | cut --delimiter ' ' --fields 1)"
}

# check the hash of a host file against the has of a file on a container
# $1: container id
# $2: host file path
# $3: container file path
assert_not_hashes()
{
  assertNotEquals "hashes for '$(basename "$2")' are ==" \
    "$(md5sum "$2" | cut --delimiter ' ' --fields 1)"    \
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
  assertContains "$archived_files" tools/logger.sh
  assertContains "$archived_files" tools/harvester.bash
  assertContains "$archived_files" tools/install_fish.sh
  assertContains "$archived_files" tools/install_kubectl.sh
  assertContains "$archived_files" tools/launch-rancher.bash
  assertContains "$archived_files" tools/airgapped-upgrade.bash
}

test_config_package_with_only_bash_fish()
{
  "$config_sh" with-fish with-bash > /dev/null 2>&1

  archived_files="$(tar --list --file "$archive")"

  assertContains "$archived_files" .bashrc
  assertContains "$archived_files" config.fish
  assertContains "$archived_files" config.json
  assertContains "$archived_files" install.sh
  assertContains "$archived_files" tools/install_fish.sh

  assertNotContains "$archived_files" tools/docker-login.sh
  assertNotContains "$archived_files" tools/cp-harv-iso.bash
  assertNotContains "$archived_files" tools/get-harv-config.bash
  assertNotContains "$archived_files" tools/logger.sh
  assertNotContains "$archived_files" tools/harvester.bash
  assertNotContains "$archived_files" tools/install_kubectl.sh
  assertNotContains "$archived_files" tools/launch-rancher.bash
  assertNotContains "$archived_files" tools/airgapped-upgrade.bash
}

test_config_install()
{
  "$config_sh" with-all > /dev/null 2>&1

  container_id=$(docker run --detach --mount type=bind,source="$archive",target=/myjournal.tar.gz "$test_image")

  docker exec "$container_id" rm /root/.bashrc
  docker exec "$container_id" tar --extract --file /myjournal.tar.gz > /dev/null 2>&1
  docker exec "$container_id" /myjournal-config/install.sh > /dev/null 2>&1

  # shell configurations
  assert_hashes "$container_id" "$journal_dir/shells/bash/config/.bashrc" /root/.bashrc
  assert_hashes "$container_id" "$journal_dir/shells/fish/config/config.fish" /root/.config/fish/config.fish

  # docker tools
  assert_hashes "$container_id" "$journal_dir/docker/tools/docker-login.sh" /root/tools/docker-login.sh

  # harvester tools
  assert_hashes "$container_id" "$journal_dir/harvester/tools/cp-harv-iso.bash" /root/tools/cp-harv-iso.bash
  assert_hashes "$container_id" "$journal_dir/harvester/tools/airgapped-upgrade.bash" /root/tools/airgapped-upgrade.bash
  assert_hashes "$container_id" "$journal_dir/harvester/tools/harvester.bash" /root/tools/harvester.bash

  # other tools
  assert_hashes "$container_id" "$journal_dir/tools/logger.sh" /root/tools/logger.sh
  assert_hashes "$container_id" "$journal_dir/shells/fish/tools/install_fish.sh" /root/tools/install_fish.sh
  assert_hashes "$container_id" "$journal_dir/kubernetes/tools/install_kubectl.sh" /root/tools/install_kubectl.sh
  assert_hashes "$container_id" "$journal_dir/rancher/tools/launch-rancher.bash" /root/tools/launch-rancher.bash

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
  assert_hashes "$container_id" "$journal_dir/shells/fish/tools/install_fish.sh" /root/tools/install_fish.sh

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
  assert_hashes "$container_id" "$journal_dir/shells/fish/tools/install_fish.sh" /root/tools/install_fish.sh

  assertEquals 'echo another hello world' "$(docker exec "$container_id" cat /root/.config/fish/another_config.fish)"

  docker container stop "$container_id" > /dev/null 2>&1
  docker container rm "$container_id" > /dev/null 2>&1
}