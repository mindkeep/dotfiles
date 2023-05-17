# ~/.profile: executed by the command interpreter for login shells.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

SHENV_LOG="${SHENV_LOG+$SHENV_LOG\n}.profile in $(date)"

DOTFILES=${DOTFILES:-$HOME}

# If we are running interactively
if [[ "$-" == *i* ]]; then

  # do we REALLY_USE_BASH?
  if [[ -n ${REALLY_USE_BASH+xxx} ]]; then
    echo "oh fine, we'll REALLY_USE_BASH"
  # bash is nice, but zsh is where want to be...
  else
    ZSH=$(which zsh)
    if [[ -n "${ZSH}" ]]; then
      echo "switching to zsh -l"
      export SHELL=${ZSH}
      exec ${ZSH} -l
    else
      echo "zsh not found!!!!!!!!!!"
    fi
  fi
  
  # include .bashrc if it exists
  if [[ -f "$DOTFILES/.bashrc" ]]; then
    . "$DOTFILES/.bashrc"
  fi
fi

# the default umask is set in /etc/profile
umask 027

SHENV_LOG="${SHENV_LOG+$SHENV_LOG\n}.profile out $(date)"
# vim: ft=bash
