#!/bin/bash
ICON=$HOME/Pictures/lock_med.png
TMPBG=/dev/shm/screen.png
scrot /dev/shm/screen.png
convert $TMPBG -scale 10% -scale 1000% $TMPBG
convert $TMPBG $ICON -gravity center -composite -matte $TMPBG
i3lock -ef -I 15 -i $TMPBG
