# Author:       Ruchika Parshionikar
# Created: 06th May 2023
# Last Modified: 06th May 2023

# Description: This pyspark application is converting json data into csv format

import os
from pyspark.sql import SparkSession
# from pyspark.sql.functions import col,explode
import pyspark.sql.functions as F
from datetime import datetime as dt


spark = SparkSession.builder.master("yarn").appName("Json-to-csv").enableHiveSupport().getOrCreate()
sc = spark.sparkContext

log4jLogger = sc._jvm.org.apache.log4j 
LOGGER = log4jLogger.LogManager.getLogger("Json-to-csv")

srcPath = "/home/talentum/zomato_etl/source/json"
destPath = "file:///home/talentum/zomato_etl/source/csv"


rm_csv = "/home/talentum/zomato_etl/source/csv/*"
os.system(f"rm -rf {rm_csv}")

LOGGER.info("---------------Reading json files-------------------")
# enumerate(sorted(os.listdir(srcPath))):
for i,file in enumerate(sorted(os.listdir(srcPath))):
    # Reading the json file
    json_df = spark.read.json("file://"+srcPath+"/"+file)

    # selecting the required column, exploding & aliasing
    explode_df = json_df.select(F.explode(F.col("restaurants.restaurant")).alias("clm"))

    # selecting the required 20 columns with the help of alias clm
    final_df = explode_df.select(F.col("clm.R.res_id").alias("Restaurant_Id"),
                                 F.col("clm.name").alias("Restaurant Name"),
                                 F.col("clm.location.country_id").alias("Country Code"),
                                 F.col("clm.location.city").alias("City"),
                                 F.col("clm.location.address").alias("Address"),
                                 F.col("clm.location.locality").alias("Locality"),
                                 F.col("clm.location.locality_verbose").alias("Locality Verbose"),
                                 F.col("clm.location.longitude").alias("Longitude"),
                                 F.col("clm.location.latitude").alias("Latitude"),
                                 F.col("clm.cuisines").alias("Cuisines"),
                                 F.col("clm.average_cost_for_two").alias("Average Cost for two"),
                                 F.col("clm.currency").alias("currency"),
                                 F.col("clm.has_table_booking").alias("Has table booking"),
                                 F.col("clm.has_online_delivery").alias("Has Online delivery"),
                                 F.col("clm.is_delivering_now").alias("Is delivering now"),
                                 F.col("clm.Switch_to_order_menu").alias("Switch to order menu"),
                                 F.col("clm.price_range").alias("Price range"),
                                 F.col("clm.user_rating.aggregate_rating").alias("Aggregate rating"),
                                 F.col("clm.user_rating.rating_text").alias("Rating text"),
                                 F.col("clm.user_rating.votes").alias("Votes"))

    # Converting into csv format
    final_df.write.csv("file:///home/talentum/zomato_etl/source/csv/Zomato.csv", mode="append",sep='\t')

    LOGGER.info("------------------Json files converted to csv files------------------")   
spark.stop()