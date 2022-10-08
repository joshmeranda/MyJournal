export GOPATH=$HOME/go

# set fish_user_paths /usr/sbin $HOME/.local/bin $HOME/.cargo/bin/ $GOPATH/bin
fish_add_path /usr/sbin $HOME/.local/bin $HOME/.cargo/bin/ $GOPATH/bin

set fish_greeting ''

if status is-interactive
    alias ls='ls --color=auto -l --group-directories-first --human-readable'
    alias clr='clear'
    alias cls='clear;ls'
    alias sudoi='sudo -i'
fi

# keep running a command until it succeeds
function wait_for
    while not eval $argv 2> /dev/null ; sleep 1; echo -n '.'; end;
end

alias wf='wait_for'

# Fish takes a long time to go through additional test and business logic
# before it tells us it can't find the given command. Instead we just want to
# know that no command was found.
function fish_command_not_found
    echo "Command '$argv[1]' not found :("
end

# if fish version < 3.2.0 we need to define an event handler
# function __fish_command_not_found_handler --on-event fish_command_not_found
#      fish_command_not_found $argv
# end

