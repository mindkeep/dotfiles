# ~/.zshrc file

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

SHENV_LOG="${SHENV_LOG+$SHENV_LOG\n}.zshrc in $(date)"

DOTFILES=${DOTFILES:-$HOME}

if [[ -f $DOTFILES/.shrc.common ]]; then
	setopt shwordsplit
	. $DOTFILES/.shrc.common
	unsetopt shwordsplit
fi

function setup_prompt {

        local NORMAL="%b%F{default}"
        local RED="%B%F{red}"
        local DARKRED="%b%F{red}"
        local GREEN="%B%F{green}"
        local BLUE="%B%F{blue}"
        local NL=$'\n'

	# ret code on error
	local PRINT_RET="%(?..[$DARKRED%?$NORMAL]$NL)"
        # Setup a red prompt for root and a green one for users.
	# user@host:path
	local HOST_PATH="%(!.$RED.$GREEN)%n@%m$NORMAL:$BLUE%~$NORMAL"

	setopt prompt_subst
	# stitch it together with vcs info
        PS1="${PRINT_RET}${HOST_PATH}\${vcs_info_msg_0_}$NL%# "

        if [[ $EUID == 0 ]] ; then
                export USER="root"
        fi

        if [ -z "$USER" ]; then
                #opensolaris is stupid...
                export USER=$LOGNAME
        fi

        # set variable identifying the chroot you work in
        if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
                debian_chroot=$(cat /etc/debian_chroot)
                PS1="$NORMAL$debian_chroot:$PS1"
        fi
}

function setup_keys {
	bindkey -e
	# create a zkbd compatible hash;
	# to add other keys to this hash, see: man 5 terminfo
	typeset -A key

	key[Home]=${terminfo[khome]}

	key[End]=${terminfo[kend]}
	key[Insert]=${terminfo[kich1]}
	key[Delete]=${terminfo[kdch1]}
	key[Up]=${terminfo[kcuu1]}
	key[Down]=${terminfo[kcud1]}
	key[Left]=${terminfo[kcub1]}
	key[Right]=${terminfo[kcuf1]}
	key[PageUp]=${terminfo[kpp]}
	key[PageDown]=${terminfo[knp]}

	# setup key accordingly
	[[ -n "${key[Home]}"     ]]  && bindkey  "${key[Home]}"     beginning-of-line
	[[ -n "${key[End]}"      ]]  && bindkey  "${key[End]}"      end-of-line
	[[ -n "${key[Insert]}"   ]]  && bindkey  "${key[Insert]}"   overwrite-mode
	[[ -n "${key[Delete]}"   ]]  && bindkey  "${key[Delete]}"   delete-char
	[[ -n "${key[Up]}"       ]]  && bindkey  "${key[Up]}"       up-line-or-history
	[[ -n "${key[Down]}"     ]]  && bindkey  "${key[Down]}"     down-line-or-history
	[[ -n "${key[Left]}"     ]]  && bindkey  "${key[Left]}"     backward-char
	[[ -n "${key[Right]}"    ]]  && bindkey  "${key[Right]}"    forward-char
	[[ -n "${key[PageUp]}"   ]]  && bindkey  "${key[PageUp]}"   beginning-of-buffer-or-history
	[[ -n "${key[PageDown]}" ]]  && bindkey  "${key[PageDown]}" end-of-buffer-or-history

	# Finally, make sure the terminal is in application mode, when zle is
	# active. Only then are the values from $terminfo valid.
	if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
		function zle-line-init () {
			printf '%s' "${terminfo[smkx]}"
		}
		function zle-line-finish () {
			printf '%s' "${terminfo[rmkx]}"
		}
		zle -N zle-line-init
		zle -N zle-line-finish
	fi
}

function title() {
        # escape '%' chars in $1, make nonprintables visible
        local a=${(V)1//\%/\%\%}

        # Truncate command, and join lines.
        a=$(print -Pn "%40>...>$a" | tr -d "\n")
        case $TERM in
                screen*)
                        print -Pn "\e]2;$a @ $2\a" # plain xterm title
                        print -Pn "\ek$a\e\\"      # screen title (in ^A")
                        print -Pn "\e_$2   \e\\"   # screen location
                        ;;
                xterm*|putty*)
                        print -Pn "\e]2;$a @ $2\a" # plain xterm title
                        ;;
        esac
}

# precmd is called just before the prompt is printed
function precmd() {
	vcs_info
        title "zsh" "%m:%55<...<%~"
}

# preexec is called just before any command line is executed
function preexec() {
        title "$1" "%m:%35<...<%~"
}

# print a yellow ^C on interrupt
function TRAPINT() {
	print -Pn -u2 '%B%F{yellow}^C%b%F{default}'
	#return $((128+$1))
	return $1
}

# version control info
#http://arjanvandergaag.nl/blog/customize-zsh-prompt-with-vcs-info.html
#http://zsh.sourceforge.net/Doc/Release/User-Contributions.html#Version-Control-Information
#http://eseth.org/2010/hg-in-zsh.html
autoload -Uz vcs_info
#zstyle ':vcs_info:*' enable hg git bzr svn
#zstyle ':vcs_info:(hg*|git*):*' get-revision true
#zstyle ':vcs_info:(hg*|git*):*' check-for-changes true

#zstyle ':vcs_info:hg*' use-simple false
zstyle ':vcs_info:(hg*|git*):*' get-revision true
zstyle ':vcs_info:(hg*|git*):*' check-for-changes true
zstyle ':vcs_info:(hg*|git*):*' unstagedstr "+"

# rev+changes branch misc
zstyle ':vcs_info:(hg*|git*)' formats " (%s)[%b:%m]%u"
zstyle ':vcs_info:(hg*|git*)' actionformats " (%s|%a)[%b:%m]%u"

zstyle ':vcs_info:hg*:*' get-bookmarks true
zstyle ':vcs_info:hg*:*' get-mq true
zstyle ':vcs_info:hg*:*' get-unapplied true

zstyle ':vcs_info:hg*:*' patch-format " mq(%n/%c):%p"
zstyle ':vcs_info:hg*:*' nopatch-format " mq(%n/%c):%p"

zstyle ':vcs_info:hg*:*' hgrevformat "%r" # only show local rev.
zstyle ':vcs_info:hg*:*' branchformat "%b:%r" # only show branch

setup_prompt
setup_keys

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory extendedglob nomatch notify
unsetopt autocd beep

# partially stolen from http://zshwiki.org/home/examples/compquickstart
zmodload zsh/complist
autoload -Uz compinit && compinit 

### If you want zsh's completion to pick up new commands in $path automatically
### comment out the next line and un-comment the following 5 lines
zstyle ':completion:::::' completer _complete _approximate
#_force_rehash() {
#  (( CURRENT == 1 )) && rehash
#  return 1	# Because we didn't really complete anything
#}
#zstyle ':completion:::::' completer _force_rehash _complete _approximate
zstyle -e ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX + $#SUFFIX) / 3 )) )'
zstyle ':completion:*:descriptions' format "- %d -"
zstyle ':completion:*:corrections' format "- %d - (errors %e})"
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true
zstyle ':completion:*' menu select
zstyle ':completion:*' verbose yes

zstyle -e ':completion:*:default' list-colors 'reply=("${PREFIX:+=(#bi)($PREFIX:t)(?)*==02=01}:${(s.:.)LS_COLORS}")'


SHENV_LOG="${SHENV_LOG+$SHENV_LOG\n}.zshrc out $(date)"
# vim: ft=zsh
