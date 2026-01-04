locals {
  ingress_cidrs = length(var.allowed_cidr_blocks) > 0 ? var.allowed_cidr_blocks : [var.vpc_cidr]
}

resource "aws_security_group" "db" {
  name        = "${var.name}-db-sg"
  description = "Database access"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Allow from CIDRs only when allowed_sg_ids is empty (initial apply)
resource "aws_security_group_rule" "db_ingress_cidr" {
  count             = length(var.allowed_sg_ids) == 0 ? 1 : 0
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.db.id
  cidr_blocks       = local.ingress_cidrs
  description       = "Postgres from VPC"
}

# Allow from specific app SGs (safer, use on second apply to avoid TF cycle)
resource "aws_security_group_rule" "db_ingress_sg" {
  count                    = length(var.allowed_sg_ids)
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = var.allowed_sg_ids[count.index]
  description              = "Postgres from App SG"
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db-subnets"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.name}-db-subnets"
  }
}

resource "aws_db_parameter_group" "this" {
  name   = "${var.name}-pg"
  family = var.parameter_group_family

  parameter {
    name         = "rds.force_ssl"
    value        = "1"
    apply_method = "pending-reboot"
  }

  tags = {
    Name = "${var.name}-pg"
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
  parameter_group_name       = aws_db_parameter_group.this.name
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
