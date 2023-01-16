#!/usr/bin/env sh
# docker-login is a utility to make it easier to store docker access tokens (in not-quite-plain-text) and manage
# multiple accounts if needed

usage="Usage: $(basename $0) <command> <args...>

commands:
  add <username> <plain-token>  add a user and token pair
  remove <username>             remove a user and token pair
  login <username>              authenticate the given user with docker hub using the stored token
  list                          list available users
"

token_dir="$HOME/.local/docker-login"

# assert_file ensures that $1 is a file, and exits if not
assert_file() {
	if [ ! -e "$1" ]; then
		echo "could not find token file for user '$(echo "$1" | cut -d . -f 1)'"
		exit 2
	elif [ -d "$1" ]; then
		echo "file '$1' is a directory"
		exit 2
	fi
}

command_add() {
	local username="$1"
	local plain_token="$2"

	if [ -z "$username" ]; then
		echo -e "expected username but found none\n$usage"
		exit 1
	elif [ -z "$plain_token" ]; then
		echo "expected token but found none\n$usage"
		exit 1
	fi

	local user_file="$token_dir/$username.token"

	if [ -e "$user_file" ]; then
		echo "file already exists for user '$username'"
		exit 2
	fi

	mkdir --parents "$token_dir"
	echo "$plain_token" | base64 > "$user_file"
}

command_remove() {
	local username="$1"
	local user_file="$token_dir/$username.token"

	assert_file "$user_file"

	rm "$user_file"
}

command_login() {
	local username="$1"

	if [ -z "$username" ]; then
		echo -e "expected username but found none\n$usage"
		exit 1
	fi

	local user_file="$token_dir/$username.token"

	assert_file "$user_file"

	local token="$(base64 --decode "$user_file")"

	if ! echo "$token" | docker login --password-stdin --username "$username"; then
		exit 2
	fi
}

command_list() {
	if [ ! -e "$token_dir" ]; then
		return
	fi

	ls "$token_dir" | cut -d . -f 1
}

if [ "$#" -eq 0 ]; then
	printf "expected command but found none\n$usage"
	exit 1
fi

command=$1
shift

case $command in
	add)
		command_add "$@"
		 ;;
	remove)
		command_remove "$@"
		;;
	login)
		command_login "$@"
		;;
	list)
		command_list
		;;
	*)
		echo -e "unknown command '$command'\n$usage"
		;;
esac
