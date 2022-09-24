export GOPATH=/home/josh/GolandProjects
export PATH=$PATH:/usr/sbin:$HOME/.local/bin:$HOME/.cargo/bin:$GOPATH/bin

alias ls='ls --color=auto --group-directories-first -l'
alias clr='clear'
alias cls='clear;ls'
alias sudoi='sudo -i'

# kill a process by name, very useful for programs that just won't quit (I'm looking at you steam)
foff()
{
  kill -9 $(pgrep -f "$@")
}

# keep running a command until it succeeds
wait_for()
{
  while not eval $* 2> /dev/null; sleep 1; echo -n '.'; done
}

alias wf=wait_for
