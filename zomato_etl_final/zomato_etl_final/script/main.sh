#!/bin/bash/

# Author:		    Ruchika parshionikar
# Created Date:		09-05-2023
# Modified Date:	09-05-2023

# Description:		This bash file is the main entry point to  zomato_etl project.
#                   Activities performed- 1. Environment setup (setup.sh)
#                                          2. Running modules

# Usage:		    bash main.sh

# Pre-requisite:    1) Mail configuration settings are required in order to send mail
#                   2) Hadoop services are running on your system
#                   3) Your home folder is there on HDFS, Hive ware house is set on hdfs to /user/hive/warehouse
#                   4) Hive metastore and Hiveserver2 services are running

echo -e "\n----------------------START-------------------------"
echo -e "\n-------------Setting up project environment------------------"
bash setup.sh
if [ $? -eq 0 ];
then
    echo "\nWhich module you would like to run ?"
    echo "1 - Module 1"
    echo "2 - Module 1 and Module 2"
    echo "Enter appropriate number to run module(1-2):"
    while true; do
        read num
        case $num in
            1) bash module_1.sh; break ;;
            2) 
                bash module_1.sh
                bash module_2.sh; break;;
            *) echo "Enter valid number...." ;;
        esac
    done       
else
    echo -e "\n-------------Setup is required to run an application--------------------"
fi
