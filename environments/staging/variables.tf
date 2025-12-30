variable "region"         { type = string }
variable "name"           { type = string }
variable "vpc_id"         { type = string }
variable "subnet_id"      { type = string }
variable "ssh_cidr"       { type = string }
variable "instance_type"  { type = string  default = "t3.small" }
variable "key_name"       { type = string }
variable "zone_id"        { type = string }
variable "app_domain"     { type = string }
variable "acme_email"     { type = string }
variable "backend_image"  { type = string }
variable "frontend_image" { type = string }
variable "use_ecr"        { type = bool    default = false }
variable "expose_dashboard" { type = bool  default = false }
variable "dashboard_domain" { type = string default = "" }
variable "basic_auth_hash"  { type = string default = "" }
