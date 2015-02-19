#!/bin/sh

cd $HOME

DOTFILES_SRC=${DOTFILES_SRC:-"$HOME/dotfiles"}

FILE_LIST="
bash_profile
bashrc
kshrc
logout
profile
screenrc
shrc.common
vim
vimrc
Xdefaults
xinitrc
zshrc"

for file in $FILE_LIST; do
	sfile="$DOTFILES_SRC/$file"
	dfile=".$file"
	rm -rf $dfile; ln -s $sfile $dfile
done

rm -rf .zprofile; ln -s $DOTFILES_SRC/profile .zprofile
rm -rf .zlogout; ln -s $DOTFILES_SRC/logout .zlogout
rm -rf .bash_logout; ln -s $DOTFILES_SRC/logout .bash_logout
