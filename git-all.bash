#!/bin/bash

function usage {
	echo "USAGE: git-all status|push|pull [origin <remote>]"
	echo ""
	echo "git-all will push or pull all git repositories found one level deeper than your current location."
	echo "Note : git usage."
	echo "	git status : detailled status of the change to add, commit or push."
	echo "	git add <file> : file to add for next commit."
	echo "	git commit -m \"<message>\" : commit file adding comment on the change."
	echo "	git push -u origin master: push the commit on github."
	echo "	git checkout : come back to previous files before modifications."
	exit
}

if [ "$1" == "push" ] || [ "$1" == "pull" ]; then
	FOUND=0
	SUCCESS=0
	FAIL=0
	BASEDIR=`pwd`

	for d in $(find . -maxdepth 1 -type d)
	do
		d=`basename $d`
		if [ -d ${BASEDIR}/${d}/.git ]; then
			FOUND=$(($FOUND + 1))
			cd ${BASEDIR}/${d}
			git $1 $2 $3

			if [ $? -eq 0 ]; then
				SUCCESS=$(($SUCCESS + 1))
			else
				FAIL=$(($FAIL + 1))
				echo "git-all: Error while ${1}ing repo `pwd`"
			fi
			echo ""
		fi
	done
	echo "git-all-${1}: $FOUND repositories found. $SUCCESS repositories affected."
	if [ $FAIL -gt 0 ]; then
		echo "git-all-${1}: $FAIL errors occurred. Check console log for details."
	fi
	exit 0
fi

if [ "$1" == "status" ]; then
	BASEDIR=`pwd`
	for d in `find . -maxdepth 1 -type d`; do
		d=`echo $d | sed -e 's/\.\///g'`
		if [ -d ${BASEDIR}/${d}/.git ]; then
			cd ${BASEDIR}/${d}
			if [ `git status | wc -l` -gt 2 ]; then
				echo "Repository '$d' has outstanding changes."
				echo "Use git status to check in detail what the change are."
				echo "Used git add to add the changed files."
				echo "Use git commit -m \"message\" to add the description for the change."
			fi
		fi
	done
	exit 0
fi

usage
