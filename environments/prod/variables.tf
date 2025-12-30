variable "region" {
  type    = string
  default = "us-east-1"
}

variable "name" {
  type    = string
  default = "salao-prod"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "db_name" {
  type    = string
  default = "salao"
}

variable "db_username" {
  type    = string
  default = "appuser"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_engine_version" {
  type    = string
  default = "15.5"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_multi_az" {
  type    = bool
  default = false
}

variable "db_skip_final_snapshot" {
  type    = bool
  default = true
}

variable "db_deletion_protection" {
  type    = bool
  default = false
}

variable "db_backup_retention" {
  type    = number
  default = 7
}

variable "media_bucket_name" {
  type = string
}

variable "s3_force_destroy" {
  type    = bool
  default = false
}

# App/EC2 variables
variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "enable_ssh" {
  type    = bool
  default = false
}

variable "ssh_cidr" {
  type    = string
  default = ""
}

variable "key_name" {
  type    = string
  default = ""
}

variable "app_domain" {
  type    = string
  default = "salao.andrepombo.info"
}

variable "acme_email" {
  type    = string
  default = "you@example.com"
}

variable "backend_image" {
  type = string
}

variable "frontend_image" {
  type = string
}

variable "use_ecr" {
  type    = bool
  default = false
}

variable "expose_dashboard" {
  type    = bool
  default = false
}

variable "dashboard_domain" {
  type    = string
  default = ""
}

variable "basic_auth_hash" {
  type    = string
  default = ""
}
