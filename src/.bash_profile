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
  elif [[ -f /bin/zsh ]]; then
    echo "switching to zsh -l"
    export SHELL=/bin/zsh
    exec /bin/zsh -l
  else
    echo "/bin/zsh not found!!!!!!!!!!"
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
