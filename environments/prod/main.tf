module "vpc" {
  source = "../../modules/vpc"

  name                 = var.name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "db" {
  source = "../../modules/rds"

  name                         = var.name
  vpc_id                       = module.vpc.vpc_id
  vpc_cidr                     = module.vpc.vpc_cidr
  subnet_ids                   = module.vpc.private_subnet_ids
  db_name                      = var.db_name
  db_username                  = var.db_username
  db_password                  = var.db_password
  engine_version               = var.db_engine_version
  instance_class               = var.db_instance_class
  allocated_storage            = var.db_allocated_storage
  multi_az                     = var.db_multi_az
  publicly_accessible          = false
  skip_final_snapshot          = var.db_skip_final_snapshot
  deletion_protection          = var.db_deletion_protection
  backup_retention_period      = var.db_backup_retention
  allowed_cidr_blocks          = []
}

module "media_bucket" {
  source = "../../modules/s3"

  bucket_name     = var.media_bucket_name
  force_destroy   = var.s3_force_destroy
  versioning      = true
  block_public_access = true
  tags = {
    Name = "${var.name}-media"
  }
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "db_endpoint" {
  value = module.db.endpoint
}

output "media_bucket" {
  value = module.media_bucket.bucket_id
}
