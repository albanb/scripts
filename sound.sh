#!/bin/bash

case $1 in
	mute)
	#Test du mute du Master
	if amixer get Master | grep "Mono" | grep -q "\[on\]"
	then
		amixer set Master mute
	else
		amixer set Master unmute
	fi
	;;
	up)
	amixer set Master 1%+
	;;
	down)
	amixer set Master 1%-
	;;
esac
