resource "tls_private_key" "default" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "default" {
  for_each   = local.aws_key_pair
  key_name   = each.value.key_name
  public_key = each.value.public_key

  tags = {
    Name = each.value.key_name
  }
}

resource "aws_vpc" "default" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.project}-${var.environment}-vpc"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "${var.project}-${var.environment}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id
  tags = {
    Name = "${var.project}-${var.environment}-route-table-public"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_route_table_association" "public_subnet_assoc" {
  for_each       = aws_subnet.default
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Split the CIDR block into subnets based on the number of availability zones, not relevant for the current example. Just testing that the code works.
resource "aws_subnet" "default" {
  for_each                = local.aws_subnet.public
  vpc_id                  = aws_vpc.default.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = "true"

  tags = {
    Name = each.value.name
  }
}

resource "aws_security_group" "default" {
  for_each    = local.aws_security_group
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.default.id

  tags = {
    Name = each.value.name
  }

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = each.value.egress
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }

  }
}

# Create an NIC and EC2 instance using the specified AMI and key pair
# I will use first subnet(AZ with index 0) and bouth security groups for the NIC.
resource "aws_network_interface" "default" {
  subnet_id       = aws_subnet.default[data.aws_availability_zones.available.names[0]].id
  security_groups = [aws_security_group.default["public_web"].id, aws_security_group.default["ssh"].id]

  tags = {
    Name = "${var.project}-${var.environment}-ec2-nic"
    az   = data.aws_availability_zones.available.names[0]
  }
}

resource "aws_instance" "default" {
  ami           = data.aws_ami.default.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.default["ec2ssh"].key_name

  network_interface {
    network_interface_id = aws_network_interface.default.id
    device_index         = 0
  }

  tags = {
    Name = "${var.project}-${var.environment}-ec2-instance"
  }

  lifecycle {
    ignore_changes = [key_name]
  }
}

# Allocate an Elastic IP and associate it with the EC2 instance created
resource "aws_eip" "default" {
  instance = aws_instance.default.id
  tags = {
    Name = "${var.project}-${var.environment}-ec2-eip"
  }
}

# Prepere for the ansible run
resource "local_file" "private_key" {
  content         = tls_private_key.default.private_key_pem
  filename        = "${path.module}/ec2_ssh_key.pem"
  file_permission = "0600"
}

# Wait for the EC2 instance to be in a running state before proceeding
resource "time_sleep" "default" {
  depends_on = [aws_instance.default]
  create_duration = "300s"
}

# test that ansible is instlled and working
resource "null_resource" "ansible_test" {
  triggers = { always_run = timestamp() }
  provisioner "local-exec" { command = "ansible --version" }
  depends_on = [ time_sleep.default ]
}

resource "null_resource" "ansible" {
  depends_on = [aws_instance.default, local_file.private_key, null_resource.ansible_test]
  triggers   = { always_run = timestamp() }
  provisioner "local-exec" {
    command = <<-EOT
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
        -i '${aws_instance.default.public_ip},' \
        -u '${var.ec2_user}' \
        --private-key='${local_file.private_key.filename}' \
        ${path.module}/ansible/nginx.yml \
        > ${path.module}/${aws_instance.default.public_ip}-ansible.log 2>&1
    EOT
  }
}