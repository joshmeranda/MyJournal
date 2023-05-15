#!/usr/bin/env sh
# docker-login is a utility to make it easier to store docker access tokens (in not-quite-plain-text) and manage
# multiple accounts if needed

usage="Usage: $(basename $0) <command> <args...>

commands:
  add <username> <plain-token> [server]
                        add a user and token pair, is no server is specified 'docker.io' is assumed
  remove <username>     remove a user and token pair
  login <username>      authenticate the given user with docker hub using the stored token
  show <username>       show the token for a user
  list                  list available users
"

storage_path="$HOME/.docker-login.json"

token_key=token
server_key=server

command_add() {
	username="$1"
	plain_token="$2"
	server="$3"

	if [ -z "$username" ]; then
		printf "expected username but found none\n%s" "$usage"
		exit 1
	elif [ -z "$plain_token" ]; then
		printf "expected token but found none\n%s" "$usage"
		exit 1
	fi

	if [ "$(jq "has(\"$username\")" "$storage_path")" = true ]; then
		printf "entry already exists for user '%s'" "$username"
		exit 1
	fi

	token="$(echo "$plain_token" | base64)"

	if [ -n "$server" ]; then
		out="$(jq ".$username.$token_key=\"$token\" | .$username.$server_key=\"$server\"" "$storage_path")"
	else
		out="$(jq ".$username.$token_key=\"$token\"" "$storage_path")"
	fi

	echo "$out" > "$storage_path"
}

command_remove() {
	username="$1"

	if [ "$(jq "has(\"$username\")" "$storage_path")" = false ]; then
		printf "no entry for user '%s' exists" "$username"
		exit 1
	fi

	out="$(jq "del(.$username)" "$storage_path")"
	echo "$out" > "$storage_path"
}

command_login() {
	username="$1"

	if [ -z "$username" ]; then
		printf "expected username but found none\n%s" "$usage"
		exit 1
	fi

	token="$(jq -r ".$username.$token_key" "$storage_path" | base64 --decode)"

	if [ "$(jq ".$username | has(\"$server_key\")" "$storage_path")" = true ]; then
		server="$(jq ".$username.$server_key" "$storage_path")"
	fi

	if ! echo "$token" | docker login --password-stdin --username "$username" "$server"; then
		exit 2
	fi
}

command_show() {
	username="$1"

	if [ -z "$username" ]; then
		printf "expected username but found none\n%s" "$usage"
		exit 1
	fi

	token="$(jq -r ".$username.$token_key" "$storage_path" | base64 --decode)"

	echo $token
}

command_list() {
	if [ ! -e "$storage_path" ]; then
		return
	fi

	jq 'keys' .docker-login.json | tail -n +2 | head -n -1 | tr --delete '"' | tr --delete , | tr --delete ' '
}

if [ "$#" -eq 0 ]; then
	printf "expected command but found none\n%s" "$usage"
	exit 1
fi

command=$1
shift

if [ ! -e "$storage_path" ]; then
	echo '{}' > "$storage_path"
fi

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
	show)
		command_show "$@"
		;;
	list)
		command_list
		;;
	*)
		printf "unknown command '%s'\n%s" "$command" "$usage"
		;;
esac
