#!/bin/bash
# Copyright 2013 Markus Lux modified by Alban Brillat

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.



# ======================================================================
# Edit the following two variables to your needs
#
# $PASS_FILE optimally should contain an absolute path, because it is not 
# guaranteed that the script gets called from the same directory
# The plain password file contains entries in the form sitename,user,password
# and may be encrypted with the following command: 
# 
# gpg -e -r <gpg_identity> <password_file>
#
# A plain text sample file is distributed in this directory: sample-passwords.txt
#
# $GPG_IDENTITY is your personal GPG identity you want to 
# crypt the password file with.
#
# $PASS_LENGTH determines the length of generated passwords.
ENCRYPTED_PASS_FILE='/home/alban/.local/share/password.gpg' #FILL ME
PASS_FILE='/tmp/password' #FILL ME
GPG_IDENTITY='alban_brillat@yahoo.fr' #FILL ME
PASS_LENGTH='15'
source "$HOME/.config/themes/dmenu-theme"
# ======================================================================

# Reload the encrypted file as a decrypted file in RAM
function reload
{
	gpg --no-tty --quiet -d "$ENCRYPTED_PASS_FILE" > "$PASS_FILE"
}

# Returns all keys present in the password file.
function getkeys
{
	while IFS=$'\t' read -r site user passwd
	do
		passwords+=( ["$site"]="$user"$'\t'"$passwd" )
	done < "$PASS_FILE" #<(gpg --no-tty --quiet -q -d "$PASS_FILE" | sed "/^$/d")
	key=$(printf "%s\n" "${!passwords[@]}" | dmenu -i -fn $FONT -nf $NORMFGND -nb $NORMBGND -sb $SELBGND -sf $SELFGND -p "Select:")
	login=${passwords[$key]}
	user=${login%$'\t'*}
	password=${login#*$'\t'}
}

# Gets a login as a string "user pass".
function get
{
	getkeys
	type=$(echo -e "$user\n$password" | dmenu -i -fn $FONT -nf $NORMFGND -nb $NORMBGND -sb $SELBGND -sf $SELFGND)
	xdotool type -- "$type"
}

# Adds an entry to the password file.
function add
{
	if [[ $# -eq 3 ]]; then
		site=$1
		user=$2
		pass=$3
	elif [[ $# -eq 2 ]]; then
		site=$1
		user=$2
		pass=$(pwgen -s1 "$PASS_LENGTH")
		echo "generated password for $user: $pass"
	elif [[ $# -lt 2 ]]; then
		echo "not enough arguments specified..."
		return
	fi

	line="$site\t$user\t$pass"

	passes=$(gpg --no-tty --quiet -d "$ENCRYPTED_PASS_FILE")

	if [[ $? -eq 0 ]]; then
		passes+='\n'
		passes+=$line
		echo -e "$passes" | gpg -e -r $GPG_IDENTITY > "$ENCRYPTED_PASS_FILE"
		echo -e "$passes" > "$PASS_FILE" #| gpg -e -r $GPG_IDENTITY > "$PASS_FILE"
	fi
}

# Deletes an entry from the password file
function del
{
	if [[ -n "$1" ]]; then
		while IFS=$'\t' read -r site user passwd
		do
			if [[ "$site" != "$1" ]]
			then
				lines+=( "$site"$'\t'"$user"$'\t'"$passwd" )
			fi
		done < <(gpg --no-tty --quiet -d "$ENCRYPTED_PASS_FILE")

		if [[ $? -eq 0 ]]
		then
			printf "%s\n" "${lines[@]}" > "$PASS_FILE"
			printf "%s\n" "${lines[@]}" | gpg -e -r $GPG_IDENTITY > "$ENCRYPTED_PASS_FILE"
		fi
	fi
}

# Fills credentials by selecting the desired site with dmenu in a browser form
# by typing the credentials with user<tab>password<enter>.
function fillbrowser
{
	getkeys
	if [[ -n "$user" ]]; then
		xdotool type -- "$user"
		xdotool key Tab
		xdotool type -- "$password"
		xdotool key Return
	fi
}

# This has to be done to allow empty parameters (e.g. for user-less logins).
params=''
for i in "$@"
do
	params="$params '$i'"
done

declare -A passwords
# The script parameters determine which method gets called.
eval "$params"
