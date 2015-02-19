# ~/.profile: executed by the command interpreter for login shells.

SHENV_LOG="${SHENV_LOG+$SHENV_LOG\n}.profile in $(date)"

DOTFILES=${DOTFILES:-$HOME}

# the default umask is set in /etc/profile
umask 027

SHENV_LOG="${SHENV_LOG+$SHENV_LOG\n}.profile out $(date)"
# vim: ft=sh
