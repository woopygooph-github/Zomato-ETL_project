#!/bin/bash/

# Author:			Ruchika parshionikar
# Created Date:		06-05-2023
# Modified Date:	06-05-2023

# Description:		This bash file when executed will check if directories already exists or not, if not it will create new directories.

# Usage:			create_directory.sh

# Pre-requisite:	

PROJECT_PATH="/home/talentum/zomato_etl"
echo "---Checking if zomato_etl and zomato_raw_files already exists in /home/talentum/-------"
if [ ! -d $PROJECT_PATH ];
then 
	echo "----------Directories doesn't exist--------------"
	echo "----------Creating New Directories---------------"
	mkdir -p $PROJECT_PATH/{source/{json,csv},archive,hive/{ddl,dml},spark/python,script,logs}/
	if [ $? -eq 0 ];
	then 
		echo "---------Created directory successfully----------"
	else
		echo "-------ERROR IN CREATING DIRECTORY------------"
		exit 1
	fi
else
	echo "----------DIRECTORIES ALREADY EXISTS----------------"
fi
