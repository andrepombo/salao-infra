data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "app" {
  name        = "${var.name}-sg"
  description = "Allow SSH, HTTP, HTTPS"
  vpc_id      = var.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "ssh" {
  count             = var.enable_ssh ? 1 : 0
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.app.id
  cidr_blocks       = [var.ssh_cidr]
  description       = "SSH"
}

resource "aws_security_group_rule" "http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.app.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTP"
}

resource "aws_security_group_rule" "https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.app.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTPS"
}

resource "aws_security_group_rule" "portainer" {
  type              = "ingress"
  from_port         = 9000
  to_port           = 9000
  protocol          = "tcp"
  security_group_id = aws_security_group.app.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Portainer UI"
}

resource "aws_iam_role" "ec2" {
  name = "${var.name}-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecr_ro" {
  count      = var.use_ecr ? 1 : 0
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_policy" "s3_rw" {
  # Only controlled by the explicit flag; the bucket name itself may be an
  # unknown during planning (coming from another module), which cannot be used
  # in a count expression.
  count  = var.s3_rw_access ? 1 : 0
  name   = "${var.name}-s3-rw"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["s3:PutObject", "s3:GetObject", "s3:DeleteObject", "s3:ListBucket"],
      Resource = [
        "arn:aws:s3:::${var.media_bucket_name}",
        "arn:aws:s3:::${var.media_bucket_name}/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "s3_rw" {
  count      = var.s3_rw_access ? 1 : 0
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.s3_rw[0].arn
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.name}-instance-profile"
  role = aws_iam_role.ec2.name
}

resource "aws_instance" "app" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = concat([aws_security_group.app.id], var.additional_sg_ids)
  iam_instance_profile        = aws_iam_instance_profile.ec2.name
  key_name                    = var.key_name != "" ? var.key_name : null
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/user_data.tpl", {
    app_domain       = var.app_domain
    acme_email       = var.acme_email
    backend_image    = var.backend_image
    frontend_image   = var.frontend_image
    expose_dashboard = var.expose_dashboard
    dashboard_domain = var.dashboard_domain
    basic_auth_hash  = var.basic_auth_hash
    use_ecr          = var.use_ecr
    region           = var.region
    db_host          = var.db_host
    db_name          = var.db_name
    db_user          = var.db_user
    db_password      = var.db_password
    db_port          = var.db_port
    media_bucket     = var.media_bucket_name
  })

  tags = { Name = var.name }
}

resource "aws_eip" "app" {
  domain   = "vpc"
  instance = aws_instance.app.id
}

resource "aws_route53_record" "app" {
  count   = var.create_dns_record ? 1 : 0
  zone_id = var.zone_id
  name    = var.app_domain
  type    = "A"
  ttl     = 60
  records = [aws_eip.app.public_ip]
}
