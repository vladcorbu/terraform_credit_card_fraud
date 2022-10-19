import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext, DynamicFrame
from awsglue.job import Job
from pyspark.sql.functions import * 

args = getResolvedOptions(sys.argv, ["JOB_NAME"])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

data_source = glueContext.create_dynamic_frame.from_catalog(
    database="transactions_credit_cards",
    table_name="transactions"
).toDF()

splitted_data = data_source.withColumn("splitted", split(col("transaction"), ",")).select(
    col('splitted').getItem(0).alias("Time"),
    col('splitted').getItem(1).alias("V1"),
    col('splitted').getItem(2).alias("V2"),
    col('splitted').getItem(3).alias("V3"),
    col('splitted').getItem(4).alias("V4"),
    col('splitted').getItem(5).alias("V5"),
    col('splitted').getItem(6).alias("V6"),
    col('splitted').getItem(7).alias("V7"),
    col('splitted').getItem(8).alias("V8"),
    col('splitted').getItem(9).alias("V9"),
    col('splitted').getItem(10).alias("V10"),
    col('splitted').getItem(11).alias("V11"),
    col('splitted').getItem(12).alias("V12"),
    col('splitted').getItem(13).alias("V13"),
    col('splitted').getItem(14).alias("V14"),
    col('splitted').getItem(15).alias("V15"),
    col('splitted').getItem(16).alias("V16"),
    col('splitted').getItem(17).alias("V17"),
    col('splitted').getItem(18).alias("V18"),
    col('splitted').getItem(19).alias("V19"),
    col('splitted').getItem(20).alias("V20"),
    col('splitted').getItem(21).alias("V21"),
    col('splitted').getItem(22).alias("V22"),
    col('splitted').getItem(23).alias("V23"),
    col('splitted').getItem(24).alias("V24"),
    col('splitted').getItem(25).alias("V25"),
    col('splitted').getItem(26).alias("V26"),
    col('splitted').getItem(27).alias("V27"),
    col('splitted').getItem(28).alias("V28"),
    col('splitted').getItem(29).alias("Amount"),
    col('splitted').getItem(30).alias("Class"),
    col('splitted').getItem(31).alias("client_id")
)

splitted_data.repartition(1) \
    .write \
    .format("parquet") \
    .mode("append") \
    .option("header", "true") \
    .save("s3://kinesis-test-bucket-lic/")

job.commit()