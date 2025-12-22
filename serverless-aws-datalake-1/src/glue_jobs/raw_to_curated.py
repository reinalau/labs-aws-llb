import sys
import boto3
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame

args = getResolvedOptions(sys.argv, ['JOB_NAME', 'DATABASE_NAME', 'RAW_BUCKET', 'CURATED_BUCKET'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# DEBUG: Imprimir valores recibidos
print("=" * 50)
print(f"DATABASE_NAME: {args['DATABASE_NAME']}")
print(f"RAW_BUCKET: {args['RAW_BUCKET']}")
print(f"CURATED_BUCKET: {args['CURATED_BUCKET']}")
print("=" * 50)

# Buscar tabla que empiece con el patrón
glue_client = boto3.client('glue')
tables = glue_client.get_tables(DatabaseName=args['DATABASE_NAME'])['TableList']
table_name = next((t['Name'] for t in tables if t['Name'].startswith('latam_data_lake_raw_dev_')), 'sales')
print(f"Tabla encontrada: {table_name}")

# Leer desde el catálogo
datasource = glueContext.create_dynamic_frame.from_catalog(
    database=args['DATABASE_NAME'],
    table_name=table_name
)

# Transformaciones
applymapping = ApplyMapping.apply(
    frame=datasource,
    mappings=[
        ("order_id", "long", "order_id", "int"),
        ("customer_id", "long", "customer_id", "int"),
        ("amount", "double", "amount", "double"),
        ("country", "string", "country", "string")
    ]
)

# Convertir a DataFrame de Spark para eliminar duplicados
df = applymapping.toDF()

# DEBUG: Ver datos antes de deduplicar
print(f"Total registros ANTES de dedup: {df.count()}")
df.show(10)
print("Schema:")
df.printSchema()

df_deduped = df.dropDuplicates()

# DEBUG: Ver datos después de deduplicar
print(f"Total registros DESPUÉS de dedup: {df_deduped.count()}")
df_deduped.show(10)

# Convertir de vuelta a DynamicFrame
deduped_frame = DynamicFrame.fromDF(df_deduped, glueContext, "deduped_frame")

# Escribir a S3 curated CON PARTICIONES
glueContext.write_dynamic_frame.from_options(
    frame=deduped_frame,
    connection_type="s3",
    connection_options={
        "path": f"s3://{args['CURATED_BUCKET']}",
        "partitionKeys": ["country"]  # Particiona por país
    },
    format="parquet"
)

job.commit()