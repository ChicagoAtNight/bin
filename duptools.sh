#!/bin/bash
export PASSPHRASE=YOU_PASSHRASE

# directories, space separated
SOURCE="/home/aelman"
LOGFILE=/home/aelman/logs/duplicity.log
# set email to receive a backup report
EMAIL="chicagoatnite@gmail.com"

backup() {
  INCLUDE=""
  for CDIR in $SOURCE
  do
    TMP=" --include  ${CDIR}"
    INCLUDE=${INCLUDE}${TMP}
  done
  # perform an incremental backup to root, include directories, exclude everything else, / as reference.
  duplicity --full-if-older-than 30D $INCLUDE --exclude '**' / $BUCKET > $LOGFILE
  if [ -n "$EMAIL" ]; then
    mail -s "backup report" $EMAIL < $LOGFILE
  fi
}

list() {
  duplicity list-current-files $BUCKET
}

restore() {
  if [ $# = 2 ]; then
    duplicity restore --file-to-restore $1 $BUCKET $2
  else
    duplicity restore --file-to-restore $1 --time $2 $BUCKET $3
  fi
}

status() {
  duplicity collection-status $BUCKET
}

if [ "$1" = "backup" ]; then
  backup
elif [ "$1" = "list" ]; then
  list
elif [ "$1" = "restore" ]; then
  if [ $# = 3 ]; then
    restore $2 $3
  else
    restore $2 $3 $4
  fi
elif [ "$1" = "status" ]; then
  status
else
  echo "
  duptools - manage duplicity backup

  USAGE:

  ./duptools.sh backup
  ./duptools.sh list
  ./duptools.sh status
  ./duptools.sh restore file [time] dest
  "
fi

export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export PASSPHRASE=
