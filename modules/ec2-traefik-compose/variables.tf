variable "region" { type = string }
variable "name"   { type = string }

variable "vpc_id"    { type = string }
variable "subnet_id" { type = string }

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "ssh_cidr" {
  type    = string
  default = ""
}

variable "enable_ssh" {
  type    = bool
  default = false
}

variable "key_name" {
  type    = string
  default = ""
}

variable "additional_sg_ids" {
  type    = list(string)
  default = []
}

variable "app_domain" {
  type    = string
  default = ""
}

variable "acme_email" {
  type    = string
  default = ""
}

variable "backend_image" {
  type    = string
  default = ""
}

variable "frontend_image" {
  type    = string
  default = ""
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

variable "create_dns_record" {
  type    = bool
  default = false
}

variable "zone_id" {
  type    = string
  default = ""
}

# DB and S3 integration (optional)
variable "db_host" {
  type    = string
  default = ""
}

variable "db_name" {
  type    = string
  default = ""
}

variable "db_user" {
  type    = string
  default = ""
}

variable "db_password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "db_port" {
  type    = number
  default = 5432
}

variable "media_bucket_name" {
  type    = string
  default = ""
}

variable "s3_rw_access" {
  type    = bool
  default = true
}
