#!/usr/bin/env bash
set -euo pipefail

OUT="terraform.tfvars"
REGION=${REGION:-$(aws configure get region 2>/dev/null || echo "us-east-1")}
NAME=${NAME:-salao-prod}
APP_DOMAIN=${APP_DOMAIN:-salao.andrepombo.info}
ACME_EMAIL=${ACME_EMAIL:-you@example.com}

# Optional: autodetect your current IP for SSH allowlist (disabled by default)
MYIP=$(curl -fsSL https://checkip.amazonaws.com || echo "0.0.0.0")

# Random suffix for unique bucket name
SUFFIX=$(openssl rand -hex 3)
BUCKET=${BUCKET:-"salao-andrepombo-media-${SUFFIX}"}

# Images (set your own)
BACKEND_IMAGE=${BACKEND_IMAGE:-"REPLACE_ME_BACKEND_IMAGE"}
FRONTEND_IMAGE=${FRONTEND_IMAGE:-"REPLACE_ME_FRONTEND_IMAGE"}

cat >"${OUT}" <<EOF
region = "${REGION}"
name   = "${NAME}"

# VPC defaults are fine; override if needed
# vpc_cidr             = "10.0.0.0/16"
# public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]
# private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]

# RDS
db_name               = "salao"
db_username           = "appuser"
db_password             = "$(openssl rand -base64 24 | tr -d '\n')"
db_engine_version       = "15.5"
db_instance_class       = "db.t3.micro"
db_allocated_storage    = 20
# db_multi_az           = false
db_skip_final_snapshot  = false
db_deletion_protection  = true
db_backup_retention     = 7

# S3
media_bucket_name = "${BUCKET}"
# s3_force_destroy = false

# App/EC2
instance_type     = "t3.small"
enable_ssh        = false
ssh_cidr          = "${MYIP}/32"
key_name          = ""  # optional when enable_ssh=true
app_domain        = "${APP_DOMAIN}"
acme_email        = "${ACME_EMAIL}"
backend_image     = "${BACKEND_IMAGE}"
frontend_image    = "${FRONTEND_IMAGE}"
use_ecr           = false
expose_dashboard  = false
dashboard_domain  = ""
basic_auth_hash   = ""
EOF

echo "Wrote ${OUT}. Review and edit images, ACME email, and any other values before 'make plan'."
