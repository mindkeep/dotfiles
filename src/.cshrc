# ~/.cshrc: executed by the command interpreter for login shells.

if ( $?prompt ) then
        # csh is ... well terrible, but zsh is where want to be...
        if ( -f /bin/zsh ) then
                echo "switching to zsh -l"
                setenv SHELL /bin/zsh
                exec /bin/zsh -l
        else
                echo "/bin/zsh not found!!!!!!!!!!"
        endif
endif

# the default umask is set in /etc/profile
umask 027

# vim: ft=csh
