data "aws_iam_policy_document" "kinesis_firehose_stream_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "kinesis_firehose_access_bucket_assume_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.kinesis_target_bucket.arn,
      "${aws_s3_bucket.kinesis_target_bucket.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "kinesis_firehose_access_glue_assume_policy" {
  statement {
    effect    = "Allow"
    actions   = ["glue:GetTableVersions", "glue:GetTable", "glue:GetTableVersion"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "kinesis_firehose_stream_role" {
  name               = "kinesis_firehose_stream_role"
  assume_role_policy = data.aws_iam_policy_document.kinesis_firehose_stream_assume_role.json
}

resource "aws_iam_role_policy" "kinesis_firehose_access_bucket_policy" {
  name   = "kinesis_firehose_access_bucket_policy"
  role   = aws_iam_role.kinesis_firehose_stream_role.name
  policy = data.aws_iam_policy_document.kinesis_firehose_access_bucket_assume_policy.json
}

resource "aws_iam_role_policy" "kinesis_firehose_access_glue_policy" {
  name   = "kinesis_firehose_access_glue_policy"
  role   = aws_iam_role.kinesis_firehose_stream_role.name
  policy = data.aws_iam_policy_document.kinesis_firehose_access_glue_assume_policy.json
}

resource "aws_iam_role" "transactions_credit_card_role" {
  name               = "transactions_credit_card_role"
  assume_role_policy = data.aws_iam_policy_document.glue-assume-role-policy.json
}

data "aws_iam_policy_document" "glue-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "policy" {
  name        = "transactions_credit_card"
  description = "transactions_credit_card"
  policy      = data.aws_iam_policy_document.policy-document.json
}

data "aws_iam_policy_document" "policy-document" {
  statement {
    actions = [
      "s3:GetBucketLocation", "s3:ListBucket", "s3:ListAllMyBuckets",
    "s3:GetBucketAcl", "s3:GetObject"]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.kinesis_target_bucket.id}",
      "arn:aws:s3:::${aws_s3_bucket.kinesis_target_bucket.id}/*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "policy-attachment" {
  role       = aws_iam_role.transactions_credit_card_role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_role_policy_attachment" "glue-service-role-attachment" {
  role       = aws_iam_role.transactions_credit_card_role.name
  policy_arn = data.aws_iam_policy.AWSGlueServiceRole.arn
}

data "aws_iam_policy" "AWSGlueServiceRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}


resource "aws_iam_role" "glue_job_role" {
  name               = "glue_role"
  assume_role_policy = data.aws_iam_policy_document.glue-assume-role-policy.json
}


data "aws_iam_policy_document" "glue_access_bucket_assume_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
      "glue:GetTableVersions",
      "glue:GetTable",
      "glue:GetTableVersion",
      "glue:GetPartitions"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "glue_s3_access_policy" {
  name        = "glue_s3_access_policy"
  description = "glue_s3_access_policy"
  policy      = data.aws_iam_policy_document.glue_access_bucket_assume_policy_document.json
}

resource "aws_iam_role_policy" "glue_job_policy" {
  name   = "glue_job_policy"
  role   = aws_iam_role.glue_job_role.name
  policy = data.aws_iam_policy_document.glue_access_bucket_assume_policy_document.json
}


