#!/bin/bash/

# Author:		Ruchika parshionikar
# Created Date:		07-05-2023
# Modified Date:	07-05-2023

# Description:		This bash file will copy first three files from zomato_raw_files to /home/talentum/zomato_etl/source/json/ folder.

# Usage:		bash copy_files.sh

# Pre-requisite:

echo "-------------Checking if /home/talentum/zomato_etl/source/json/ contains files-----------"
if [ -z "$(ls -A /home/talentum/zomato_etl/source/json/)" ];
then
	echo "----------/home/talentum/zomato_etl/source/json/ is empty--------------"
	cp /home/talentum/zomato_raw_files/file[1-3].json /home/talentum/zomato_etl/source/json/
	if [ $? -eq 0 ];
	then
		echo "---------Required files copied successfully--------"
	else
		echo "--------Error in copying files----------"
		exit 1
	fi
else
	echo "----------/home/talentum/zomato_etl/source/json/ is not Empty-------------"
fi
