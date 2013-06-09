#!/bin/sh

#Determine if it is a plug profile
function plug()
{
	if echo $1 | grep -q "^ethernet"
	then
		return 0
	fi
	return 1
}

#Determine if it is a wifi profile
function wifi()
{
	if echo $1 | grep -q "^wireless"
	then
		return 0
	fi
	return 1
}

#Determine if a wifi module is loaded
function wifiLoaded()
{
	if lsmod | grep -q iwlwifi
	then
		return 0
	fi
	return 1
}

function startProfile()
{
	#If it is a cable connection start it and disable wifi if loaded
	if plug $1
	then
		netctl start $1
		#Check if wifi module is loaded and remove it
		if wifiLoaded
		then
			modprobe -r iwldvm
			modprobe -r iwlwifi
		fi
	#else if wifi connection
	elif wifi $1
	then
		#if wifi module not loaded yet
		if ! wifiLoaded
		then
			#Load wifi module
			modprobe iwlwifi
		fi
		#Start the wifi profile
		netctl start $1
	#cannot assume if it is wireless or plug profile, do not do anything
	else
		echo "net.sh error : impossible to determine the profile type (cable or wifi)"
		return 1
	fi
}

#Check that the profile exists
if [ ! -e /etc/netctl/$1 ]
then
	echo "net.sh error : profile $1 does not exist"
	exit 1
fi

#Record the loaded profile
lastProfile=$(netctl list | sed -n 's/^\* //p')
#Check if the profile is a new one or if the profile is already loaded
	#Profile already loaded
	if [[ "$lastProfile" != "" && "$lastProfile" = "$1" ]]
	then
		netctl restart "$1"
	#Last profile to stop, new profile to load
	elif [[ "$lastProfile" != "" ]]
	then
		netctl stop $lastProfile
		startProfile $1
	#New profile to load
	else
		startProfile $1
	fi
