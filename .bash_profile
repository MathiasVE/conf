# source the users bashrc if it exists
if [ -f "${HOME}/.bashrc" ] ; then
  source "${HOME}/.bashrc"
fi

# source the users bashrc if it exists
if [ -f "${HOME}/.bash_aliases" ] ; then
  source "${HOME}/.bash_aliases"
fi

# Set PATH so it includes user's private bin if it exists
if [ -d "${HOME}/bin" ] ; then
  PATH="${HOME}/bin:${PATH}"
fi

# Set MANPATH so it includes users' private man if it exists
if [ -d "${HOME}/man" ]; then
  MANPATH="${HOME}/man:${MANPATH}"
fi

# Set INFOPATH so it includes users' private info if it exists
if [ -d "${HOME}/info" ]; then
   INFOPATH="${HOME}/info:${INFOPATH}"
fi

# Use xterm-256color
export TERM=xterm-256color

# Useful git aliases for submodules 
git config alias.sdiff '!'"git diff && git submodule foreach 'git diff'"
git config alias.spush 'push --recurse-submodules=on-demand'
git config alias.supdate 'submodule update --remote --merge'

# TODO: should seek to reattach to old session if it still exists after kill -9 of bash process
session="tmux-main-session"
if ! (tmux has-session -t "$session" 2> /dev/null) && [ "$TMUX" = "" ]; then
	echo "INIT TMUX SESSION $session"
	tmux new-session -d -s "$session"
	tmux attach -t "$session"
fi

function exit() {
	if [[ -z $TMUX ]]; then
		if (tmux has-session -t "$session" 2> /dev/null) && [ "$TMUX" = "" ]; then
			tmux kill-session -t "$session"
		fi
		builtin exit
	elif [ $(tmux list-panes | wc -l) -le 1 ]; then
		tmux detach
	else
		builtin exit
	fi
}
