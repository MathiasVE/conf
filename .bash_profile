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
git config --global alias.sdiff '!'"git diff && git submodule foreach 'git diff'"
git config --global alias.spush 'push --recurse-submodules=on-demand'
git config --global alias.supdate 'submodule update --remote --merge'
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.mylog "log --pretty=format:'%h %s [%an]' --graph"
git config --global alias.lol "log --graph --decorate --pretty=oneline --abbrev-commit --all"

# get current branch in git repo
function parse_git_branch() {
	BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
	if [ ! "${BRANCH}" == "" ]
	then
		STAT=`parse_git_dirty`
		echo "[${BRANCH}${STAT}]"
	else
		echo ""
	fi
}

# get current status of git repo
function parse_git_dirty {
	status=`git status 2>&1 | tee`
	dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
	untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
	ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
	newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
	renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
	deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
	bits=''
	if [ "${renamed}" == "0" ]; then
		bits=">${bits}"
	fi
	if [ "${ahead}" == "0" ]; then
		bits="*${bits}"
	fi
	if [ "${newfile}" == "0" ]; then
		bits="+${bits}"
	fi
	if [ "${untracked}" == "0" ]; then
		bits="?${bits}"
	fi
	if [ "${deleted}" == "0" ]; then
		bits="x${bits}"
	fi
	if [ "${dirty}" == "0" ]; then
		bits="!${bits}"
	fi
	if [ ! "${bits}" == "" ]; then
		echo " ${bits}"
	else
		echo ""
	fi
}

# See for mercurial integration
export PS1="\[\e[35m\]\u\[\e[m\]@\[\e[32m\]\h\[\e[m\]:\[\e[36m\]\w\[\e[m\]\[\e[33m\]\`parse_git_branch\` \[\e[m\]"


function exit() {
	if [[ -z $TMUX ]]; then
		# TODO: will attach child process to the INIT process :s
		# if (tmux has-session -t "$session" 2> /dev/null) && [ "$TMUX" = "" ]; then
		# 	tmux kill-session -t "$session"
		# fi
		builtin exit
	elif [ $(tmux list-panes | wc -l) -le 1 ] && [ $(tmux list-windows | wc -l) -le 1 ]; then
		tmux detach
	else
		builtin exit
	fi
}

# Fix java heap space allocation
case "`uname`" in
  CYGWIN*) 
	  peflags --cygwin-heap=1024 ~/workspace/NSF/infrastructure/jdk1.7.0_51/Windows/jdk1.7.0_51/bin/java.exe > /dev/null 2>&1;
	  peflags --cygwin-heap=1024 ~/jdk/jdk1.7.0_51/Windows/jdk1.7.0_51/bin/java.exe > /dev/null 2>&1;
	  # Errors are ignored as it simply indicates that the file is in use and most likely the option was already set
	  ;;
esac

if [ -f "${HOME}/.ns_scripts" ] ; then
  source "${HOME}/.ns_scripts"
fi

# Easy to find text recursively starting from the current directory
quick_search() {
if [ $# -eq 0 ]; then
	echo "Please specify a word to look for"
else
	find . -type f -print0 | xargs -0 grep -l $1
fi
}

# TODO: should seek to reattach to old session if it still exists after kill -9 of bash process
session="tmux-main-session"

if [ "$TMUX" = "" ]; then # Only attach when the shell is not running inside TMUX already
# Only initialize a new tmux session when the session does not exists
if ! (tmux has-session -t "$session" 2> /dev/null) && [ "$TMUX" = "" ]; then
	echo "INIT 2 TMUX SESSION $session"
	tmux new-session -d -s "$session"
	tmux rename-window "general"
	tmux new-window -k -n "notes" 'vim ~/notes/improve_ideas'
	tmux new-window -k -n "jonas"
	tmux split-window 'tail -f ~/logs/gc.log'
	tmux split-window '~/jdk/jvmtop.sh'
        tmux new-window -k -n "stadim"
	tmux new-window -k -n "startit"
fi
tmux attach -t "$session"
fi

hgdiff() {
if [ $# -eq 0 ]; then
	pushd . > /dev/null;
	cd ~/workspace/NSF/$NS_WS/descriptors;
	for f in $(hg status | grep "M " | cut -d ' ' -f2); # TODO: see if I can skip deleted files
	do
		vimdiff -c 'map q :qa!<CR>' <(hg cat "$f") "$f";
	done;
	popd > /dev/null;
else
	vimdiff -c 'map q :qa!<CR>' <(hg cat "$1") "$1";
fi
}

untar() {
	tar -xvf $1
}
