#!/bin/sh

function clean()
{
    echo "clean *.zip"
    rm -rf *.zip
}

if [ "$1" = "clean" ]
then
    clean
else
    clean

    zip -r 1_majorSoftware_inst.zip 1_majorSoftware_inst

    zip -r 2_majorService_inst.zip 2_majorService_inst

    zip -r 3_juniorService_inst.zip 3_juniorService_inst

    zip -r 4_juniorSoftware_inst.zip 4_juniorSoftware_inst 
fi
