#!/bin/bash/

# Author:		    Ruchika parshionikar
# Created Date:		06-05-2023
# Modified Date:	06-05-2023

# Description:		This bash file when executed will , run pySpark file to convert json files to csv,create zomato_summary_log table on hive and load data into zomato_summary_log table.

# Usage:		    bash module_1.sh

# Pre-requisite: 1) All the services are running (hdfs,yarn,hivemetastore,hiveserver2)
            #    2) On Hdfs you have /user/hive/warehouse
            #    3) A setup.sh run successfully
            #    4) You have zomato_etl directory structure on local file system

# source./zomato.properties
PROJECT_PATH="/home/talentum/zomato_etl"
declare dbname=default
declare tablename=zomato_summary_log

#function for generating logs in a file and loading it to zomato_summary_log table on hive 
function load_data(){
    # declare log_file="log_$(date +%d%m%Y_%H%M%S).log"
    declare log_file="log_$(date +%d%m%Y_%H%M%S)"
    touch $PROJECT_PATH/logs/$log_file.log
    echo "$1" >> $PROJECT_PATH/logs/$log_file.log
    beeline -u jdbc:hive2://localhost:10000/$dbname -n hiveuser -p Hive@123 \
    -f $PROJECT_PATH/hive/dml/raw_summary_log_dml.hive --hivevar dbname=$dbname --hivevar tablename=$tablename --hivevar filename=$log_file.log
    # &>/dev/null
    exitFunc
    }

#after adding logs into table, moving json files to ~/zomato_etl/archive/ and removing tmp folder indicating that application running is over
function exitFunc(){
    mv $PROJECT_PATH/source/json/* $PROJECT_PATH/archive/
    rm -r $PROJECT_PATH/tmp/
    exit 0
}

#checking if application is already running or not
if [ -d $PROJECT_PATH/tmp ]; then
    echo -e "\n-------------APPLICATION IS RUNNING.............."
    exit 1
else
    echo -e "\n--------MODULE 1 : STARTED RUNNING---------"
    startTime=`date +"%F %H:%M:%S"` 
    mkdir -p $PROJECT_PATH/tmp/MODULE_1_INPROGRESS
    
    jobid=`date +%Y:%m:%d:%T`
    jobstep="Module_1"
    pyFile_loc="spark-submit --master yarn --deploy-mode cluster --driver-java-options -Dlog4j.configuration='file:///home/talentum/spark/conf/log4j.properties' $PROJECT_PATH/spark/python/Json-to-csv.py" 
    
    
    #creating zomato_summary_log table on hive
    beeline -u jdbc:hive2://localhost:10000/$dbname -n hiveuser -p Hive@123 \
    -f $PROJECT_PATH/hive/ddl/zomato_summary_log_ddl.hive --hivevar dbname=$dbname --hivevar tablename=$tablename

    if [ $? -ne 0 ]; then
        status="FAILURE"
        echo -e "\n---------------------MODULE 1 : FAILED-----------------------"
        # echo "Status Update: $status"|mail -s $jobstep ruchikaparshionikar@gmail.com
        echo -e "\nProject Name: zomato_etl" "\nStatus Update: " $status "\nJob id: " $jobid "\nJob step : " $jobstep | mail -s $jobstep ruchikaparshionikar@gmail.com
        echo -e "\nMail sent to Project manager................!!!"
        load_data "$jobid,$jobstep,$pyFile_loc,$startTime,$(date +"%F %H:%M:%S"),$status"
        exit 1
    else
        unset PYSPARK_DRIVER_PYTHON
        unset PYSPARK_DRIVER_PYTHON_OPTS

        #pyspark application to convert json files to csv files
        $pyFile_loc
        if [ $? -ne 0 ]; then
            status="FAILURE"
            echo -e "\n---------------------MODULE 1 : FAILED-----------------------"
            echo "Status Update: $status"|mail -s $jobstep ruchikaparshionikar@gmail.com
            echo -e "\n................Mail sent to Project manager................!!!"
            load_data "$jobid,$jobstep,$pyFile_loc,$startTime,$(date +"%F %H:%M:%S"),$status"
            exit 1
        fi    
        #renaming csv files and moving it to ~/zomato_etl/source/csv/
        for f in $PROJECT_PATH/source/csv/Zomato.csv/part*.csv
        do
            mv $f $PROJECT_PATH/source/csv/zomato_$(date +'%Y%m%d_%H%M%S').csv
            sleep 1s
        done

        #Deleting Zomato.csv from ~/zomato_etl/csv
        rm -rf $PROJECT_PATH/source/csv/Zomato.csv
        if [ $? -eq 0 ]; then
            status="SUCCESS"
            echo -e "\n---------------------MODULE 1 : COMPLETED-------------------"
            echo -e "\nProject Name: zomato_etl" "\nStatus Update: " $status "\nJob id: " $jobid "\nJob step : " $jobstep | mail -s $jobstep ruchikaparshionikar@gmail.com
            load_data "$jobid,$jobstep,$pyFile_loc,$startTime,$(date +"%F %H:%M:%S"),$status"  
        else
            #sending mail to project manager if module 1 is failing
            status="FAILURE"
            echo -e "\n---------------------MODULE 1 : FAILED-----------------------"
            # echo "Status Update: " $status | mail -s $jobstep ruchikaparshionikar@gmail.com
            echo -e "\nProject Name: zomato_etl" "\nStatus Update: " $status "\nJob id: " $jobid "\nJob step : " $jobstep | mail -s $jobstep ruchikaparshionikar@gmail.com
            echo -e "\nMail sent to Project manager................!!!"
            load_data "$jobid,$jobstep,$pyFile_loc,$startTime,$(date +"%F %H:%M:%S"),$status"
            exit 1
        fi
    fi
fi

