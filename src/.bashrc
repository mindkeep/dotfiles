# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything, this must be first
[ -z "$PS1" ] && return

SHENV_LOG="${SHENV_LOG+$SHENV_LOG\n}.bashrc in $(date)"

DOTFILES=${DOTFILES:-$HOME}

# do we REALLY_USE_BASH?
if [[ -n ${REALLY_USE_BASH+xxx} ]]; then
  echo "oh fine, we'll REALLY_USE_BASH"
# bash is nice, but zsh is where want to be...
elif [[ -f /bin/zsh ]]; then
  echo "switching to zsh"
  export SHELL=/bin/zsh
  exec /bin/zsh
else
  echo "/bin/zsh not found!!!!!!!!!!"
fi

if [ -f $DOTFILES/.shrc.common ]; then
  . $DOTFILES/.shrc.common
fi

function set_prompt {

  local NORMAL="\[\e[0m\]"
  local RED="\[\e[1;31m\]"
  local GREEN="\[\e[1;32m\]"
  local BLUE="\[\e[1;34m\]"

  # Setup a red prompt for root and a green one for users.
  if [[ $EUID == 0 ]] ; then
    export PS1="$RED\u@\h$NORMAL:$BLUE\w$NORMAL\n# "
    export USER="root"
  else
    export PS1="$GREEN\u@\h$NORMAL:$BLUE\w$NORMAL\n$ "
  fi

  # set variable identifying the chroot you work in
  if [[ -z "$debian_chroot" ]] && [[ -r /etc/debian_chroot ]]; then
    debian_chroot=$(cat /etc/debian_chroot)
    PS1="$NORMAL$debian_chroot:$PS1"
  fi

  if [[ -z "$USER" ]]; then
    #opensolaris is stupid...
    export USER=$LOGNAME
  fi
  if [[ "$TERM" == screen* ]]; then
    export PROMPT_COMMAND='echo -ne "\033k\033\\"'
  else
    export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
  fi

}

set_prompt

unset set_prompt

# force ignoredups and ignorespace
export HISTCONTROL=ignoreboth

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

SHENV_LOG="${SHENV_LOG+$SHENV_LOG\n}.bashrc out $(date)"
