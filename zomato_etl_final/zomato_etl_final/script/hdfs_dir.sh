
#!/bin/bash/

# Author:		Ruchika parshionikar
# Created Date:		08-05-2023
# Modified Date:	08-05-2023

# Description:		This bash file when executed will check if directories on hdfs already exists or not, if not it will create new directories.

# Usage:		bash hdfs_dir.sh

# Pre-requisite:



echo -e "\n---Checking if zomato_etl_group8 already exists in /user/talentum/....."

if hdfs dfs -test -d "/user/talentum/zomato_etl_group8"; then  #TODO : remove hardcoded path
        echo -e "\n------------Directory exists on hdfs----------------"
else
        echo -e "\n----------Directories doesn't exist--------------"
        echo -e "\n----------Creating New Directories on hdfs---------------"
        hdfs dfs -mkdir -p zomato_etl_group8/{log,zomato_ext/{zomato,dim_country}}
fi

exit 0



