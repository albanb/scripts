#!/bin/bash
PASS_FILE='/home/alban/.local/share/password.gpg' #FILL ME
[[ -f ~/.config/Xresources ]] && xrdb -merge ~/.config/Xresources
#xset +fp /usr/share/fonts/local
#xset fp rehash
#Force keyboard mapping only for xdotool (configuration in /etc/X11/xorg.conf.d/10-keyboard-layout.conf
setxkbmap fr
numlockx
gpg --no-tty --quiet -q -d "$PASS_FILE" > /tmp/password
