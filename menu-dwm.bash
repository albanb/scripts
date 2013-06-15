#!/bin/bash
#Pop up properties
source "$HOME/.config/themes/dmenu-theme"

function power()
{
	#Infos a afficher
	action=$(echo -e "eteindre\nredemarrer\nfermer" | dmenu -i -fn $FONT -nf $NORMFGND -nb $NORMBGND -sb $SELBGND -sf $SELFGND)
	#Launch tool
	case $action in
		"eteindre" )
			poweroff
		;;
		"redemarrer" )
			reboot
		;;
		"exit" )
			systemctl --user exit
		;;
	esac
}

function todo()
{
	LINES=$(todo.sh -d ~/.config/todo/config ls | wc -l)

	max=0
	for lines in $(todo.sh -d ~/.config/todo/config ls | sed "s/ /_/g")
	do
		nbcar=$(echo $lines | wc -m)
		if [ "$nbcar" -gt "$max" ]
		then
			max=$nbcar
		fi
	done
	WIDTH=$(($max*7))
	#Infos a afficher
	action=$(todo.sh -d ~/.config/todo/config ls | head -n -2 | dmenu -i -l 5 -nb $NORMBGND -nf $NORMFGND -sb $SELBGND -sf $SELFGND)
	todo.sh -d ~/.config/todo/config -fn $action
}

function umount()
{
	MOUNTED=$(ls -1 /media)

	max=0
	for lines in $(echo -e $MOUNTED | sed "s/ /_/g")
	do
		nbcar=$(echo $lines | wc -m)
		if [ "$nbcar" -gt "$max" ]
		then
			max=$nbcar
		fi
	done
	WIDTH=$(($max*7))
	#Infos a afficher
	action=$(echo -e $MOUNTED | dmenu -i -l 15 -nf $NORMFGND -nb $NORMBGND -sb $SELBGND -sf $SELFGND | sed "s+\(.*\)+/media/\1+")
	udiskie-umount -s $action
}

function notifications()
{
	LINE="15"
	LIST="torrent\ncal"

	action=$(echo -e $LIST | dmenu -i -fn $FONT -nf $NORMFGND -nb $NORMBGND -sb $SELBGND -sf $SELFGND)

	case $action in
		"torrent" )
			actions=$(grep "$1" $HOME/.local/share/dwm/notification | cut -d";" -f2| dmenu -i -l $LINE | sed -e "s/\[/\\\[/" -e "s/\]/\\\]/")
			sed "/$actions/d" $HOME/.local/share/dwm/notification | sponge $HOME/.local/share/dwm/notification
		;;
		"cal" )
			actions=$(grep "$1" $HOME/.local/share/dwm/notification | cut -d";" -f2| dmenu -i -l $LINE | sed -e "s/\[/\\\[/" -e "s/\]/\\\]/")
			sed "/$actions/d" $HOME/.local/share/dwm/notification | sponge $HOME/.local/share/dwm/notification
		;;
	esac
}

#Infos a afficher
action=$(echo -e "power\ntodo\numount\nnotifications" | dmenu -i -fn $FONT -nf $NORMFGND -nb $NORMBGND -sb $SELBGND -sf $SELFGND) 
#Launch tool
$action
