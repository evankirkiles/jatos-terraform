/*
 * ec2.tf
 * author: evan kirkiles
 * created on Sat Mar 04 2023
 * 2023 the nobot space, 
 */

/* ----------------------------- Security Groups ---------------------------- */

# Security group for SSH access to the EC2 instance. You may want to change the
# ingress CIDR blocks for more restricted SSH access.
module "dev_ssh_sg" {
  source              = "terraform-aws-modules/security-group/aws"
  name                = replace("${local.prefix}_ec2_sg", "-", "_")
  description         = "SSH security group for JATOS instance."
  vpc_id              = data.aws_vpc.default.id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]
}

# Allow HTTP connections (ports :80 and :443) to the JATOS EC2 instance. 
module "ec2_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  name        = replace("${local.prefix}_ec2_sg", "-", "_")
  description = "HTTPS security group for JATOS instance."
  vpc_id      = data.aws_vpc.default.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

/* ------------------------------- Cloud init ------------------------------- */

# We use Cloud Init to set up our Jatos instance in the AWS EC2 repo from a 
# fresh Amazon Linux 2 install. We also configure the mounts and SSL.
data "cloudinit_config" "jatos_config" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/templates/cloudinit.yaml", {
      SSL_DOMAIN_NAME : var.ssl_domain_name,
      SSL_REGISTER_EMAIL : var.ssl_register_email,
      SSL_ENABLED : var.ssl_enabled ? 1 : 0,
      FILE_JATOS_SERVICE : base64gzip(file("${path.module}/templates/jatos.service"))
      FILE_NGINX_CONF : base64gzip(templatefile("${path.module}/templates/nginx-${var.ssl_enabled ? "ssl" : "nossl"}.conf", {
        SSL_DOMAIN_NAME : var.ssl_domain_name
      }))
      FILE_JATOS_CONF : base64gzip(templatefile("${path.module}/templates/production.conf", {
        JATOS_DB_URL                 = module.db.db_instance_endpoint
        JATOS_DB_NAME                = module.db.db_instance_name
        JATOS_DB_USERNAME            = module.db.db_instance_username
        JATOS_DB_PASSWORD            = module.db.db_instance_password
        JATOS_RESULT_UPLOADS_ENABLED = var.result_uploads_enabled
      }))
      FILE_INIT_MOUNTS : base64gzip(file("${path.module}/templates/initmounts.sh"))
      FILE_INIT_SSL : base64gzip(file("${path.module}/templates/initssl.sh"))
      RESULT_UPLOADS_ENABLED : var.result_uploads_enabled ? 1 : 0
    })
  }
}

/* ------------------------------ EC2 Instance ------------------------------ */

# Linux AMI on Amazon Linux 2 for running JATOS
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

# EC2 instance with Jatos installed through userdata
resource "aws_instance" "main" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"

  root_block_device {
    volume_size = 8
  }

  # Availability zone set deterministically to match RDS and EBS
  availability_zone = var.aws_availability_zone

  # Install JATOS on the EC2 instance using cloud-config
  user_data = data.cloudinit_config.jatos_config.rendered

  # Allow SSH and HTTP traffic with our above security groups
  vpc_security_group_ids = [
    module.ec2_sg.security_group_id,
    module.dev_ssh_sg.security_group_id
  ]

  # Add key pair for SSH access
  key_name = module.key_pair.key_pair_name

  # Other various EC2 configurations
  monitoring                  = true
  disable_api_termination     = false
  ebs_optimized               = true
  user_data_replace_on_change = true
}

/* ---------------------------- Static IP Address --------------------------- */

# Allocate an Elastic IP address so the EC2 instance IP does not change on reboot.
# Note that this will incur a small hourly charge if you stop your EC2 instance!
resource "aws_eip" "main" {
  instance = aws_instance.main.id
  vpc      = true
}

/* ----------------------- Connection to EC2 instance ----------------------- */

# Key pair for connecting to EC2 instance through SSH
module "key_pair" {
  source             = "terraform-aws-modules/key-pair/aws"
  key_name           = "${local.prefix}-jatos"
  create_private_key = true
}

# Output the .pem to a local file
resource "local_file" "private_key" {
  content  = module.key_pair.private_key_pem
  filename = "ssh/jatos.pem"
}
