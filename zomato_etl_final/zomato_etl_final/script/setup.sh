#!/bin/bash/

# Author:		    Ruchika parshionikar
# Created Date:		09-05-2023
# Modified Date:	09-05-2023

# Description:		This bash file will run all scripts to setup project application. Dropping all the hive tables if exists on hive, checking required directory on HDFS is present or not, Copying json files from staging area to ~/zomato_etl/source/json, deleting files in ~/zomato_etl/archive if exists and deleting ~/zomato_etl/tmp folder if exists.

# Usage:		    bash setup.sh

# Pre-requisite:    1) Mail configuration settings are required in order to send mail
#                   2) Hadoop services are running on your system

declare dbname=default
PROJECT_PATH="/home/talentum/zomato_etl"

#Dropping all the project related hive tables
echo -e "\n------------Dropping all the tables on hive-----------------"
beeline -u jdbc:hive2://localhost:10000/$dbname -n hiveuser -p Hive@123 -f $PROJECT_PATH/hive/ddl/cleanhive.hive --hivevar dbname=$dbname 
# &>/dev/null


#setting up hdfs file location
echo -e "\n---------------DIRECTORY ON HDFS LOCATION-------------------"
bash hdfs_dir.sh


#copying json files from staging area to local system
echo -e "\n-----------Checking if ~/zomato_etl/source/json/ having required csv files-----------"
if [ -z "$(ls -A $PROJECT_PATH/source/json/)" ];
then
    echo -e "\n----------/home/talentum/zomato_etl/source/json/ is empty--------------"
    cp /home/talentum/zomato_raw_files/file{1..3}.json $PROJECT_PATH/source/json/
    if [ $? -eq 0 ];
    then
        echo -e "\n---------Required files copied successfully--------"
    else
        echo -e "\n--------Error in copying files----------"
        exit 1
    fi
else
    echo -e "\n----------/home/talentum/zomato_etl/source/json/ is already having json files-------------"
fi


echo -e "\n-------------Deleting files from ~/zomato_etl/archive/ ----------------------"
rm $PROJECT_PATH/archive/*


echo -e "\n---------------Deleting ~/zomato_etl/tmp/ folder-----------------"
rm -rf $PROJECT_PATH/tmp/
