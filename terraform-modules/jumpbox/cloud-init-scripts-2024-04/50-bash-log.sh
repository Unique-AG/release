## Disable hiding commands with space at the beginning
echo "HISTCONTROL=noignoreboth" >> /etc/bash.bashrc

## Determine remote user IP
cat <<'\EOF' >> /etc/profile
IP=$(who am i | awk '{ print $5 }' | sed 's/(//g' | sed 's/)//g')
## Put to log logged user notiify
logger -p local7.notice -t "bash $LOGNAME $$" User $LOGNAME logged from $IP
## Prefix for messages filtering (if messages logged to /var/log/messages)
PREF="usrlog"
## Logger
function h2log
{
    declare CMD
    declare _PWD
    CMD=$(history 1)
    CMD=$(echo $CMD |awk '{print substr($0,length($1)+2)}')
    _PWD=$(pwd)
    logger -p local7.notice -t bash -i -- "${PREF} : SESSION=$$ : ${IP} : ${USER} : ${_PWD} : ${CMD}"
}

trap h2log DEBUG || EXIT
\EOF