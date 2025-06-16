locals {
  aws_key_pair = {
    ec2ssh = {
      key_name   = "${var.project}-${var.environment}-public-key"
      public_key = tls_private_key.default.public_key_openssh
    }
  }

  key_pairs_list = [
    for key_pair in aws_key_pair.default :
    {
      key_name   = key_pair.key_name
      public_key = key_pair.public_key
    }
  ]

  aws_security_group = {
    public_web = {
      name        = "${var.project}-${var.environment}-public-web-sg"
      description = "Security group for public web access"
      ingress = [
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]

      egress = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1" # All protocols
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
    ssh = {
      name        = "${var.project}-${var.environment}-ssh-sg"
      description = "Security group for SSH access"
      ingress = [
        {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["${data.http.myip.response_body}/32"]
        }
      ]

      egress = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1" # All protocols
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  }

  aws_subnet = {
    public = {
      for az in data.aws_availability_zones.available.names :
      az => {
        cidr_block        = cidrsubnet(var.vpc_cidr_block, length(data.aws_availability_zones.available.names), index(data.aws_availability_zones.available.names, az))
        availability_zone = az
        name              = "${var.project}-${var.environment}-public-subnet-${az}"
      }
    }
  }
}