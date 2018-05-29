#!/bin/sh

if [ -e "common.sh" ]
then
    source ./common.sh
else
    echo "Not exit common.sh"
    return 1
fi

Ping

for file in ${FILE_LIST[*]}
do
    if [ ! -e $file ]
    then
        echo "Please run package.sh first."
        exit 1
    fi
done

if [ -e "copy.sh" ]
then
    chmod +x copy.sh
    ./copy.sh
fi

echo "Install end. Current dir: $DIR"

