# ~/.cshrc: executed by the command interpreter for login shells.

if ( $?prompt ) then
  # csh is ... well terrible, but zsh is where want to be...
  if ( -f /usr/bin/zsh ) then
    echo "switching to zsh -l"
    setenv SHELL /usr/bin/zsh
    exec /usr/bin/zsh -l
  else if ( -f /bin/zsh )
    echo "switching to zsh -l"
    setenv SHELL /bin/zsh
    exec /bin/zsh -l
  endif

  echo "zsh not found!!!!!!!!!!"

  if ( -f /usr/bin/bash ) then
    echo "switching to bash -l"
    setenv SHELL /usr/bin/bash
    exec /usr/bin/bash -l
  else if ( -f /bin/bash )
    echo "switching to bash -l"
    setenv SHELL /bin/bash
    exec /bin/bash -l
  endif

  echo "bash not found either?! WTF?!"
endif

# the default umask is set in /etc/profile
umask 027

# vim: ft=csh
