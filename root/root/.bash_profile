#
# ~/.bash_profile
#

# [[ -f ~/.bashrc ]] && . ~/.bashrc

# Start X server
[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx > ~/.xorg.log 2>&1
