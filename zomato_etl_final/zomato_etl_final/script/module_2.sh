#!/bin/bash/

# Author:		    Ruchika parshionikar
# Created Date:		10-05-2023
# Modified Date:	10-05-2023

# Description:		This bash file will  create external/managed tables (dim_country,raw_zomato,zomato) on hive and load csv file data in raw_zomato
#                   then load data from raw_zomato to zomato table.

# Usage:		    bash module_2.sh

# Pre-requisite:   1) setup.sh run successfully to setup project environment.
#                  2) module_1.sh should run before running module_2.sh.

#declaring variables
declare dbname=default
declare tablename=zomato_summary_log
declare country=dim_country
PROJECT_PATH="/home/talentum/zomato_etl"

#function to create log files and load data from log files to zomato_summary_log
function load_data(){
    declare log_file="log_$(date +%d%m%Y_%H%M%S).log"
    touch $PROJECT_PATH/logs/$log_file
    echo "$1" >> $PROJECT_PATH/logs/$log_file
    # beeline -u jdbc:hive2://localhost:10000/$dbname -n hiveuser -p Hive@123 \
    # -e "LOAD DATA LOCAL INPATH '/home/talentum/zomato_etl/logs/$log_file' INTO TABLE zomato_summary_log;"
    beeline -u jdbc:hive2://localhost:10000/$dbname -n hiveuser -p Hive@123 \
    -f $PROJECT_PATH/hive/dml/raw_summary_log_dml.hive --hivevar dbname=$dbname --hivevar tablename=$tablename --hivevar filename=$log_file
    exitFunc
    }

#after adding logs into table, deleting ~/zomato_etl/tmp/ folder  
function exitFunc(){
    rm -r $PROJECT_PATH/tmp/
    exit 0
}

#checking if application is already running or not
if [ -d $PROJECT_PATH/tmp ]; then
    echo -e "\n-------------APPLICATION IS RUNNUNG----------------"
    jobid=`date +%Y:%m:%d:%T`
    jobstep="Module_1"
    SSA="-"
    startTime=`date +"%F %H:%M:%S"`
    exit 1
else
    echo -e "\n--------MODULE 2 : STARTED RUNNING---------"
    startTime=`date +"%F %H:%M:%S"`
    mkdir -p $PROJECT_PATH/tmp/MODULE_2_INPROGRESS
    
    jobid=`date +%Y:%m:%d:%T`
    jobstep="Module_2"
    SSA="-"

    if [ $? -ne 0 ]; then
        status="FAILURE"
        echo -e "\n---------------------MODULE 2 : FAILED-----------------------"
        echo -e "\nProject Name: zomato_etl" "\nStatus Update: " $status "\nJob id: " $jobid "\nJob step : " $jobstep | mail -s $jobstep ruchikaparshionikar@gmail.com
        echo -e "\nMail sent to Project manager................!!!"
        load_data "$jobid,$jobstep,$SSA,$startTime,$(date +"%F %H:%M:%S"),$status"
    else
        echo -e "\n-------------------Creating dim_country table on hive---------------------"
        beeline -u jdbc:hive2://localhost:10000/$dbname -n hiveuser -p Hive@123 \
        -f $PROJECT_PATH/hive/ddl/createCountry.hive --hivevar dbname=$dbname --hivevar tablename=$country
        if [ $? -eq 0 ];
        then    
            echo -e "\n-------------------Loading data from country_code.csv file to dim_country table on hive---------------------\n"
            beeline -u jdbc:hive2://localhost:10000/$dbname -n hiveuser -p Hive@123 \
            -f $PROJECT_PATH/hive/dml/dim_country_dml.hive --hivevar dbname=$dbname --hivevar tablename=$country
            if [ $? -eq 0 ];
            then    
                echo -e "\n--------------Creating raw_zomato and zomato table on hive----------------\n"
                beeline -u jdbc:hive2://localhost:10000/$dbname -n hiveuser -p Hive@123 \
                -f $PROJECT_PATH/hive/ddl/createZomato.hive --hivevar dbname=$dbname
                if [ $? -eq 0 ];
                then
                    echo -e "\n-----------------Loading data from csv file to raw_zomato and then from raw_zomato to zomato table-------------\n"
                    beeline -u jdbc:hive2://localhost:10000/$dbname -n hiveuser -p Hive@123 -f $PROJECT_PATH/hive/dml/raw_zomato_dml.hive --hivevar dbname=$dbname
                    status="SUCCESS"
                    echo -e "\n---------------------MODULE 2 : COMPLETED-----------------------"
                    load_data "$jobid,$jobstep,$SSA,$startTime,$(date +"%F %H:%M:%S"),$status"
                else
                    status="FAILURE"
                    echo -e "\n---------------------MODULE 2 : FAILED-----------------------"
                    echo -e "\nProject Name: zomato_etl" "\nStatus Update: " $status "\nJob id: " $jobid "\nJob step : " $jobstep | mail -s $jobstep ruchikaparshionikar@gmail.com
                    echo -e "\n..............Mail sent to Project manager................!!!"
                    load_data "$jobid,$jobstep,$SSA,$startTime,$(date +"%F %H:%M:%S"),$status"     
                fi
            else
                status="FAILURE"
                echo -e "\n---------------------MODULE 2 : FAILED-----------------------"
                echo "Status Update: $status"|mail -s $jobstep ruchikaparshionikar@gmail.com
                echo -e "\nMail sent to Project manager................!!!" 
                load_data "$jobid,$jobstep,$SSA,$startTime,$(date +"%F %H:%M:%S"),$status"
            fi    
        else
            status="FAILURE"
            echo -e "\n---------------------MODULE 2 : FAILED-----------------------"
            echo "Status Update: $status"|mail -s $jobstep ruchikaparshionikar@gmail.com
            echo -e "\nMail sent to Project manager................!!!"  
            load_data "$jobid,$jobstep,$SSA,$startTime,$(date +"%F %H:%M:%S"),$status"
        fi    
    fi
fi
