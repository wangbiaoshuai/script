#!/bin/sh

DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd )

LOCAL_IP=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`

if [ -e "$DIR/common.sh" ]
then
    source $DIR/common.sh
else
    echo "Not exit common.sh"
    exit 1
fi

Ping

SCRIPT_PATH="/usr/local/service/script"

function login(){

SERVICE_IP=$1
SERVICE_PWD=$2

echo "Login $SERVICE_IP, password: $SERVICE_PWD"

expect <<!

set timeout -1

spawn ssh root@$SERVICE_IP

expect {
"*yes/no*"
{
    send "yes\r"
    exp_continue
}

"*password:*"
{
    send "$SERVICE_PWD\r"
}
}

expect "*]#"
send "\[ -e $SCRIPT_PATH/uninstall.sh \] && cd $SCRIPT_PATH && sh uninstall.sh\r"
expect {
"*y/n*"
{
    send "y\r"
    exp_continue
}
"*]#"
{
    send "exit\r"
}
}

expect eof
!

}

i=1
for file in ${FILE_LIST[@]}
do
    eval service_ip=\$SERVICE"$i"_IP
    if [ "$service_ip" = "$LOCAL_IP" ]
    then
        [ -e $SCRIPT_PATH/uninstall.sh ] && cd $SCRIPT_PATH && sh uninstall.sh && cd -
    else
        eval login \$SERVICE"$i"_IP \$SERVICE"$i"_PWD
    fi
    let i++
done
