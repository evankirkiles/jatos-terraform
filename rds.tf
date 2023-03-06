/*
 * rds.tf
 * author: evan kirkiles
 * created on Sat Mar 04 2023
 * 2023 the nobot space, 
 */

/* ----------------------------- Security groups ---------------------------- */

# Security group allowing EC2 instance to access the MySQL database
module "db_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  name        = replace("${local.prefix}_db_sg", "-", "_")
  description = "Security group for JATOS database."
  vpc_id      = data.aws_vpc.default.id
  ingress_with_source_security_group_id = [
    {
      description              = "Database access for JATOS"
      rule                     = "mysql-tcp"
      source_security_group_id = module.ec2_sg.security_group_id
    }
  ]
  egress_rules = ["all-all"]
}

/* --------------------------- RDS MySQL instance --------------------------- */

# Stores data from the JATOS server
module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${local.prefix}-db-mysql"

  engine               = "mysql"
  engine_version       = "8.0"
  family               = "mysql8.0"
  major_engine_version = "8.0"

  # Instance information
  instance_class    = "db.t3.micro"
  allocated_storage = 15
  storage_encrypted = true

  # Connectivity information
  db_name  = "jatos"
  username = var.db_username
  port     = 3306

  iam_database_authentication_enabled = true
  availability_zone                   = var.aws_availability_zone

  vpc_security_group_ids = [module.db_sg.security_group_id]

  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = 0

  subnet_ids          = data.aws_subnets.all.ids
  deletion_protection = false

  # Very important––set the character set and collation to UTF-8
  parameters = [
    {
      name  = "character_set_client"
      value = "utf8"
    },
    {
      name  = "character_set_connection"
      value = "utf8"
    },
    {
      name  = "character_set_database"
      value = "utf8"
    },
    {
      name  = "character_set_filesystem"
      value = "utf8"
    },
    {
      name  = "character_set_results"
      value = "utf8"
    },
    {
      name  = "character_set_server"
      value = "utf8"
    }
  ]
}