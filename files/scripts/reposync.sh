#!/bin/bash

TRIES=10 # number of times to try and run reposync
LOGFILE="/var/log/cobbler/cobbler_reposync.log"

function running {
       PID=$(ps ax| awk '/cobbler reposync/ && !/awk/ {print ($1)}')
       if [ -z $PID ]
       then
               log "cobbler reposync is not running"
               return 1
       fi
       log "cobbler reposync is running PID=$PID"
       return 0
}

function log {
       logger -t "COBBLER_REPOSYNC" -- $1
}

function run {
       try=1
       ret=1
       while [ $try -le $TRIES ]
       do
               running
               ok=$?
               if [ $ok -eq 0 ]
               then
                       log "Already running, aborting"
                       break
               fi
               log "Attempt $try for $1"
               cobbler reposync --only=$1 2>&1 >> $LOGFILE
               ret=$?
               if [ $ret -eq 0 ]
               then
                       break
               fi
               log "Attempt $try failed"
               try=$[ $try + 1 ]
       done
       if [ $ret -eq 0 ]
       then
               log "Compleated $1"
       else
               log "Too many trys or already running, giving up on $1"

       fi
}

log "Starting"
mv $LOGFILE $LOGFILE.1

for name in `cobbler repo list`
do
       run $name
done 
