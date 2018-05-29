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

if [ ! -e "/usr/bin/expect" ]
then
    echo "Not exit /usr/bin/expect, please install expect-tool first.\nPlease run: yum install expect"
    exit 1
fi

function copy() {

SERVICE_IP=$2
SERVICE_PWD=$3

echo Copy $DIR/$1 to $SERVICE_IP, password: $SERVICE_PWD, please wait...

#dots 1 &
#BG_PID=$!
#trap "kill -9 $BG_PID" INT

expect <<!

set timeout -1

spawn scp -r $DIR/$1 $DIR/common.sh $DIR/deploy.ini root@$SERVICE_IP:/

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
expect eof
!

#kill $BG_PID
#echo ""
}

function login(){

FILE=$1
SERVICE_IP=$2
SERVICE_PWD=$3

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
send "rm -rf /product/cems; mkdir -p /product/cems; mv /$FILE /common.sh /deploy.ini /product/cems; cd /product/cems; unzip $FILE; cd ${FILE%.zip}; sh install.sh\r"
expect "*]#"
send "exit\r"

expect eof
!

}

i=1
for file in ${FILE_LIST[@]}
do
    eval service_ip=\$SERVICE"$i"_IP
    if [ "$service_ip" = "$LOCAL_IP" ]
    then
        cp -r $file common.sh deploy.ini /
    else
        eval copy $file \$SERVICE"$i"_IP \$SERVICE"$i"_PWD
    fi
    let i++
    #eval echo "$file \$SERVICE"$i"_IP \$SERVICE"$i"_PWD"
done

i=1
for file in ${FILE_LIST[@]}
do
    eval service_ip=\$SERVICE"$i"_IP
    if [ "$service_ip" = "$LOCAL_IP" ]
    then
        rm -rf /product/cems; mkdir -p /product/cems; mv /$file /common.sh /deploy.ini /product/cems; cd /product/cems; unzip $file; cd ${file%.zip}; sh install.sh
    else
        eval login $file \$SERVICE"$i"_IP \$SERVICE"$i"_PWD
    fi
    let i++
done

