resource "aws_athena_database" "transactions_db" {
  name   = "transactions_credit_cards"
  bucket = aws_s3_bucket.kinesis_target_bucket.id
}

resource "aws_s3_bucket" "query_results" {
  bucket = "results-athena-credit-card"
}


resource "aws_s3_bucket_public_access_block" "query_results_bucket_block" {
  bucket                  = aws_s3_bucket.query_results.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_athena_workgroup" "workgroup" {
  name = "my_workgroup"
  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true
    result_configuration {
      output_location = "s3://${aws_s3_bucket.query_results.bucket}/output/"
    }
  }
}