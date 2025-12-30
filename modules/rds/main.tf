locals {
  ingress_cidrs = length(var.allowed_cidr_blocks) > 0 ? var.allowed_cidr_blocks : [var.vpc_cidr]
}

resource "aws_security_group" "db" {
  name        = "${var.name}-db-sg"
  description = "Database access"
  vpc_id      = var.vpc_id

  ingress {
    description = "Postgres from VPC/app"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = local.ingress_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db-subnets"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.name}-db-subnets"
  }
}

resource "aws_db_instance" "this" {
  identifier                 = "${var.name}-db"
  allocated_storage          = var.allocated_storage
  engine                     = "postgres"
  engine_version             = var.engine_version
  instance_class             = var.instance_class
  db_name                    = var.db_name
  username                   = var.db_username
  password                   = var.db_password
  port                       = 5432
  db_subnet_group_name       = aws_db_subnet_group.this.name
  vpc_security_group_ids     = [aws_security_group.db.id]
  multi_az                   = var.multi_az
  publicly_accessible        = var.publicly_accessible
  skip_final_snapshot        = var.skip_final_snapshot
  deletion_protection        = var.deletion_protection
  backup_retention_period    = var.backup_retention_period
  storage_encrypted          = true
  auto_minor_version_upgrade = true
  apply_immediately          = false
}
