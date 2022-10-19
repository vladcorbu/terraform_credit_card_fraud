resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  name        = "kinesis-stream-lic"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn        = aws_iam_role.kinesis_firehose_stream_role.arn
    bucket_arn      = aws_s3_bucket.kinesis_target_bucket.arn
    buffer_size     = 64
    buffer_interval = 60

    processing_configuration {
      enabled = "false"
    }

    data_format_conversion_configuration {
      input_format_configuration {
        deserializer {
          hive_json_ser_de {}
        }
      }

      output_format_configuration {
        serializer {
          parquet_ser_de {}
        }
      }

      schema_configuration {
        database_name = aws_athena_database.transactions_db.name
        role_arn      = aws_iam_role.kinesis_firehose_stream_role.arn
        table_name    = aws_glue_catalog_table.aws_glue_catalog_credit_card_table.name
      }
    }

  }
}

resource "aws_s3_bucket" "kinesis_target_bucket" {
  bucket = "kinesis-test-bucket-lic"
}

resource "aws_s3_bucket_public_access_block" "kinesis_target_bucket_access" {
  bucket = aws_s3_bucket.kinesis_target_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
