#!/bin/bash
#ttoggle
#
# Using the wmctrl utility to create a list of the current
# terminal windows in an effort to map their focus to numbered
# keys. For example, if i wanted to map a keyboard command
# to the third instance of a terminal window, I would use
# Ubuntu to map Ctrl-Alt-3 to ttoggle 2

# Usage: ttoggle 1 swaps focus to terminal 1

SUCCESS=0
FAILURE=1
TERMNAME=`id -un`"@"`hostname`":"

if [ -z "$1" ]; then
    echo "Usage: ttoggle <TERMINAL_INDEX>";
    exit $FAILURE
fi

isdigit() {
   [ $# -eq 1 ] || return $FAILURE # checks if letter
   case $1 in
       *[!0-9]*|"") return $FAILURE;;
       *) return $SUCCESS;; #everything else is a digit
   esac
}

# Map terminals to array indices
map_terms() {
    i=0
    for w in `wmctrl -l | grep Terminal | cut -d" " -f1`;
    do
	if [[ $1 -eq $i ]]; then
	    wmctrl -i -a $w
	fi
	i=$((i+1))
    done
    return
}

if isdigit "$@"
then
    map_terms $1
    exit $SUCCESS
else
    echo "Error: Enter a single digit"
    exit $FAILURE
fi
