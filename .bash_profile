# source the users bashrc if it exists
if [ -f "${HOME}/.bashrc" ] ; then
  source "${HOME}/.bashrc"
fi

# source the users bash_aliases if it exists
if [ -f "${HOME}/.bash_aliases" ] ; then
  source "${HOME}/.bash_aliases"
fi

# source the users bashrc if it exists
if [ -f "${HOME}/.bash_ssh" ] ; then
  source "${HOME}/.bash_ssh"
fi

# Set PATH so it includes user's private bin if it exists
if [ -d "${HOME}/bin" ] ; then
  PATH="${HOME}/bin:${PATH}"
fi

# Load extra sources from source directory
if [ -d "${HOME}/src" ] ; then
  for f in ${HOME}/src/*; do
    source "${f}";
  done
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
git config --global alias.lol "log --graph --decorate --date=iso --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%ci) %C(bold blue)<%an>%Creset' --abbrev-commit --all"

function get_java_version() {
  echo "[jdk:$JAVA_VERSION]"
}

function parse_ns_ws() {
  if [[ $(pwd) =~ /cygdrive/c/NSF-3.0/workspace_(.*)/descriptors ]]; then
    echo "[ws:${BASH_REMATCH[1]}$(get_nsf)]"
   elif [[ $(pwd) =~ /cygdrive/c/NSF-3.0/primespace/expansionsPR/(.*)-id([0-9]+) ]]; then
     echo "[exp:${BASH_REMATCH[1]}-${BASH_REMATCH[2]}$(get_nsf)]"
   elif [[ $(pwd) =~ /cygdrive/c/NSF/workspace/([^\/]*) ]]; then
    echo "[ws:${BASH_REMATCH[1]}$(get_nsf)]"
   elif [[ $(pwd) =~ /cygdrive/c/NSF/expansions/([^\/]*) ]]; then
    echo "[exp:${BASH_REMATCH[1]}$(get_nsf)]"
  fi
}

function get_nsf() {
  if [ "$GLOBAL_NSF" != "" ]; then
    echo "-$GLOBAL_NSF";
  else
    echo ""
  fi
}

function get_pr() {
  if [ "$GLOBAL_PR" != "" ]; then
    echo "[PR-$GLOBAL_PR]";
  else
    echo ""
  fi
}

function parse_git_branch() {
  BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
  if [ ! "${BRANCH}" == "" ]
  then
    STAT=`parse_git_dirty`
    echo "[git:${BRANCH}${STAT}]"
  else
    BRANCH=$(hg branch 2> /dev/null | awk '{print $1}')
    if [ ! "${BRANCH}" == "" ]; then
      HG_STATUS=$(hg status 2> /dev/null \
            | awk '$1 == "?" { print "?" } $1 != "?" { print "!" }' \
                | sort | uniq | head -c1);
      echo "[hg:${BRANCH}${HG_STATUS}]"
    else
      echo
    fi
  fi
}

function parse_ns() {
  if [ -n "$NS_WS" ]; then
    echo "[ns:${NS_WS}]"
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
# export PS1="\[\e[35m\]\u\[\e[m\]@\[\e[32m\]\h\[\e[m\]:\[\e[36m\]\w\[\e[m\]\[\e[1;31m\]\`parse_ns\`\[\e[m\]\[\e[33m\]\`parse_git_branch\` \[\e[m\]"
export PS1="\[\e[36m\]\`short_path\`\[\e[m\]\[\e[35m\]\`get_java_version\`\[\e[m\]\[\e[32m\]\`parse_ns_ws\`\[\e[m\]\[\e[32m\]\`get_pr\`\[\e[m\]\[\e[33m\]\`parse_git_branch\` \[\e[m\]"


function exit() {
  if [[ -z $TMUX ]]; then
    # TODO: will attach child process to the INIT process :s
    # if (tmux has-session -t "$session" 2> /dev/null) && [ "$TMUX" = "" ]; then
    #   tmux kill-session -t "$session"
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
    peflags --cygwin-heap=4096 /cygdrive/c/NSF/infrastructure/jdk1.6.0_22/Windows/jdk1.6.0_22/bin/java.exe > /dev/null 2>&1;
    peflags --cygwin-heap=4096 /cygdrive/c/NSF/infrastructure/jdk1.6.0_45/Windows/jdk1.6.0_45/bin/java.exe > /dev/null 2>&1;
    peflags --cygwin-heap=4096 /cygdrive/c/NSF/infrastructure/jdk1.7.0_51/Windows/jdk1.7.0_51/bin/java.exe > /dev/null 2>&1;
    peflags --cygwin-heap=4096 /cygdrive/c/NSF/infrastructure/jdk1.7.0_80/Windows/jdk1.7.0_80/bin/java.exe > /dev/null 2>&1;
    peflags --cygwin-heap=4096 /cygdrive/c/NSF/infrastructure/jdk1.8.0_73/Windows/jdk1.8.0_73/bin/java.exe > /dev/null 2>&1;
    peflags --cygwin-heap=4096 /cygdrive/c/NSF/infrastructure/jdk1.8.0_151/Windows/jdk1.8.0_151/bin/java.exe > /dev/null 2>&1;
    ;;
esac

# if [ -f "${HOME}/.ns/helper_scripts" ] ; then
#   source "${HOME}/.ns/helper_scripts"
# fi

# Easy to find text recursively starting from the current directory
quick_search() {
if [ $# -eq 0 ]; then
  echo "Please specify a word to look for"
else
  find . -type f -print0 | xargs -0 grep -l "$1"
fi
}

# TODO: should seek to reattach to old session if it still exists after kill -9 of bash process
session="tmux"

if [ "$TMUX" = "" ]; then # Only attach when the shell is not running inside TMUX already
# Only initialize a new tmux session when the session does not exists
if ! (tmux has-session -t "$session" 2> /dev/null) && [ "$TMUX" = "" ]; then
  echo "INIT 2 TMUX SESSION $session"
  tmux new-session -d -s "$session"
  tmux rename-window "main"
fi
tmux attach -t "$session"
fi

hgdiff() {
if [ $# -eq 0 ]; then
  for f in $(hg status | grep "M " | cut -d ' ' -f2); # TODO: see if I can skip deleted files
  do
    vimdiff -c 'map q :qa!<CR>' <(hg cat "$f") "$f";
  done;
else
  vimdiff -c 'map q :qa!<CR>' <(hg cat "$1") "$1";
fi
}

alias gitdiff='git difftool'

untar() {
  tar -xvf $1
}

docker_clean() {
  docker rm $(docker ps -a -q)
  docker images -q --filter "dangling=true" | xargs docker rmi
  docker volume rm $(docker volume ls -qf dangling=true)
}

mvn_init() {
  mvn archetype:generate -DgroupId=org.normalizedsystems.nsx -DartifactId="${1}" -DarchtypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
}

jdk() {
  SELECTION=$(select_from_evaluation "echo 1.6.0_45; echo 1.7.0_80; echo 1.8.0_151")
  if [ "$SELECTION" != "" ]; then
    set_jdk $SELECTION
  fi
}

set_jdk() {
  if [ $# -eq 1 ]; then
    PATH=$(echo "$PATH" | sed -e "s#/cygdrive/c/NSF/infrastructure/jdk${JAVA_VERSION}/Windows/jdk${JAVA_VERSION}/bin:##")
    export JAVA_VERSION=$1
    export JAVA_DIR="/cygdrive/c/NSF/infrastructure/jdk${JAVA_VERSION}/Windows/jdk${JAVA_VERSION}"
    export JAVA_HOME=$(cygpath -pw "${JAVA_DIR}")

    if [ -d "${JAVA_DIR}/bin" ] ; then
      PATH="${JAVA_DIR}/bin:${PATH}"
    fi
  else
    jdk
  fi
}

set_jdk "1.8.0_151"

#TODO: if evaluation only has 1 value -> auto select 
function select_from_evaluation() {
  if [ $# -eq 1 ] && ! [ -z "$PS1" ]; then
    TO_EVAL=$1
    let i=0;
    W=();
    while read -r line; do
      let i=$i+1
      W+=($i "$line")
    done < <(eval $TO_EVAL)
    if [ $i -eq 1 ]; then
      echo ${W[$i]}
    else
      SELECTION=$(dialog --title "Select" --menu "Choose one" 24 80 17 "${W[@]}" 3>&2 2>&1 1>&3)
      if [ $? -eq 0 ]; then
        SELECTION=$((SELECTION * 2))
        SELECTION=$((SELECTION - 1))
        echo ${W[$SELECTION]}
      fi
      clear 3>&2 2>&1 1>&3
    fi
  fi
}



short_path() {
  case $PWD in
    $HOME) HPWD="~";;
    $HOME/*/*) HPWD="${PWD#"${PWD%/*/*}/"}";;
    $HOME/*) HPWD="~/${PWD##*/}";;
    /*/*/*) HPWD="${PWD#"${PWD%/*/*}/"}";;
    *) HPWD="$PWD";;
  esac;
  echo $HPWD;
}

clean_timesheet() {
  ARGS="$@"
  /cygdrive/c/Program\ Files\ \(x86\)/ManicTime/Mtc.exe export ManicTime/Tags 'C:\Users\mathias.verelst\Desktop\abc-groep\timesheets\ManicTime_export.csv' "/fd:2015-01-01" "/td:2019-01-01"
  pushd . > /dev/null;
  cd ~/workspace/clean_timesheet;
  ./clean-timesheet.sh $@
  popd > /dev/null
}
