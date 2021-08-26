# .kshrc

# if not running interactively, don't do anything
[ -z "$PS1" ] && return

SHENV_LOG="${SHENV_LOG+$SHENV_LOG\n}.kshrc in $(date)"

DOTFILES=${DOTFILES:-$HOME}

if [ -f $DOTFILES/.shrc.common ]; then
  . $DOTFILES/.shrc.common
fi

function set_prompt {

  NORMAL='\E[0m]'
  RED='\E[31;1m]'
  GREEN='\E[32;1m]'
  BLUE='\E[34;1m]'
  NL="\n"

  # Setup a red prompt for root and a green one for users.
  if [[ $EUID == 0 ]] ; then
    export PS1=$'\E[31;1m$(whoami)@$(hostname)\E[0m:\E[34;1m${PWD}\E[0m\n(ksh) # '
    export USER="root"
  else
    export PS1=$'\E[32;1m$(whoami)@$(hostname)\E[0m:\E[34;1m${PWD}\E[0m\n(ksh) $ '
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
  unset NORMAL RED GREEN BLUE
}

set_prompt

unset set_prompt

SHENV_LOG="${SHENV_LOG+$SHENV_LOG\n}.kshrc out $(date)"
# vim: ft=sh
