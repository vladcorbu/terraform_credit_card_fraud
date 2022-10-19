data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_rds_engine_version" "postgresql" {
  engine  = "aurora-postgresql"
  version = "13.6"
}

module "db" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 7.0.0"

  name              = "production-aurora-postgresql"
  engine            = data.aws_rds_engine_version.postgresql.engine
  engine_version    = data.aws_rds_engine_version.postgresql.version
  engine_mode       = "provisioned"
  storage_encrypted = true

  vpc_id                = data.aws_vpc.default.id
  subnets               = data.aws_subnets.all.ids
  create_security_group = true
  allowed_cidr_blocks   = ["0.0.0.0/0"]

  create_random_password = true

  apply_immediately   = true
  publicly_accessible = true
  skip_final_snapshot = true
  master_username     = "postgres"


  monitoring_interval = 60


  serverlessv2_scaling_configuration = {
    min_capacity = 2
    max_capacity = 10
  }

  instance_class = "db.serverless"
  instances = {
    one = {}
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

resource "aws_db_parameter_group" "example_postgresql13" {
  name        = "aurora-db-postgres13-parameter-group"
  family      = "aurora-postgresql13"
  description = "aurora-db-postgres13-parameter-group"
}

resource "aws_rds_cluster_parameter_group" "example_postgresql13" {
  name        = "aurora-postgres13-cluster-parameter-group"
  family      = "aurora-postgresql13"
  description = "aurora-postgres13-cluster-parameter-group"
}