resource "aws_glue_job" "process_data_job" {
  name              = "process_data"
  role_arn          = aws_iam_role.glue_job_role.arn
  glue_version      = "3.0"
  worker_type       = "G.1X"
  number_of_workers = 2
  timeout           = 10
  max_retries       = 0


  command {
    script_location = "s3://${aws_s3_bucket.glue_bucket.bucket}/process.py"
  }
}

resource "aws_s3_bucket" "glue_bucket" {
  bucket = "glue-bucket-processs"
}

resource "aws_s3_bucket_public_access_block" "glue_bucket_access" {
  bucket = aws_s3_bucket.glue_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "py_script" {
  bucket = aws_s3_bucket.glue_bucket.id
  key    = "process.py"
  source = "./process.py"
  etag   = filemd5("./process.py")

}