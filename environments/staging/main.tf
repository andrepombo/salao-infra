module "app2" {
  source = "../../modules/ec2-traefik-compose"

  region           = var.region
  name             = var.name
  vpc_id           = var.vpc_id
  subnet_id        = var.subnet_id
  ssh_cidr         = var.ssh_cidr
  instance_type    = var.instance_type
  key_name         = var.key_name
  zone_id          = var.zone_id
  app_domain       = var.app_domain
  acme_email       = var.acme_email
  backend_image    = var.backend_image
  frontend_image   = var.frontend_image
  use_ecr          = var.use_ecr
  expose_dashboard = var.expose_dashboard
  dashboard_domain = var.dashboard_domain
  basic_auth_hash  = var.basic_auth_hash
}
