#!/bin/sh

#SOURCE="$0"
#while [ -h "$SOURCE"  ]; do # resolve $SOURCE until the file is no longer a symlink
#    DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"
#    SOURCE="$(readlink "$SOURCE")"
#    [[ $SOURCE != /*  ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
#done
#DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd )"


DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd )

function dots(){
seconds=$1 # print a dot every 5 seconds by default
while true
do
    sleep $seconds
    echo -n '.'
done
}

SERVICE1_IP="" 
SERVICE1_PWD=""
SERVICE2_IP=""
SERVICE2_PWD=""
SERVICE3_IP=""
SERVICE3_PWD=""
SERVICE4_IP="" 
SERVICE4_PWD=""

FILE_LIST=( 1_majorSoftware_inst.zip 2_majorService_inst.zip 3_juniorService_inst.zip 4_juniorSoftware_inst.zip )

echo $DIR
function parser_conf() {
i=0
while read LINE
do
    let i++
    eval SERVICE"$i"_IP=${LINE#*=}
    eval SERVICE"$i"_PWD=${LINE##*=}
done < $DIR/deploy.ini

return 0
}

function Ping()
{
    for i in {1..4}
    do
        eval ping \$SERVICE"$i"_IP -c 2 > /dev/null
        eval echo "ping \$SERVICE"$i"_IP..."
        if [ $? -ne 0 ]
        then
            eval echo "\$SERVICE"$1"_IP can not connect!"
            exit 1
        else
            eval echo "\$SERVICE"$1"_IP connected..."
        fi
    done
}

parser_conf

#echo $SERVICE1_IP $SERVICE1_PWD $SERVICE2_IP $SERVICE2_PWD $SERVICE3_IP $SERVICE3_PWD $SERVICE4_IP $SERVICE4_PWD
