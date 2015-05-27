#!/usr/bin/env bash
#
# create cygwin mirror
#
# see:  https://sourceware.org/cygwin-apps/package-server.html
#       https://cygwin.com/mirrors.html
#
#NOTE: to use script proxies would need to be set to something usable
#

#set rsync_proxy
export RSYNC_PROXY={something}

DOW=`date '+%w'`
LOGFILE="/repos/cygwin-mirror-scripts/cygwin-rsync.log.${DOW}"
REPO_PATH="/repos/cygwin"
SOURCE_PATH="rsync://mirrors.kernel.org/sourceware/cygwin/"
MSG="Cygwin files failed to synced. See ${LOGFILE} for details."
RC=1

# Checks to see if the rsync job is running. If not, it runs. This prevents the jobs from stepping on each other.
if ! ps -ef | grep -v grep | grep -q 'rsync -qaH --del rsync:\/\/mirrors.kernel.org\/sourceware\/cygwin\/ \/repos\/cygwin\/'
then
        #using loop to continue rsync when disconnect occurs
        while [ $RC -gt 0 ]
        do
#               rsync -Rdtlzvh --partial --delete --progress --stats --log-file=${LOGFILE} ${SOURCE_PATH} ${REPO_PATH}
                rsync -qaH --log-file=${LOGFILE} ${SOURCE_PATH} ${REPO_PATH}
                RC=$?
                echo "Rsync exit code was ${RC}." >> ${LOGFILE}
        done
else
        MSG="cygwin_rsync.sh already running.  Not starting"
fi

if [ $RC -ne 0 ]
then
        echo ${MSG} | mutt -s "cygwin_rsync.sh" mmm13@gmail.com
fi

gzip -f ${LOGFILE}
#
# download setup*exe files if they have an older timestamp
#
export https_proxy=https://{USER:PASSWORD}@proxyserver:8080
wget -q -N  https://cygwin.com/setup-x86.exe -O ${REPO_PATH}/setup-x86.exe
wget -q -N https://cygwin.com/setup-x86_64.exe -O ${REPO_PATH}/setup-x86_64.exe
