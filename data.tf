data "http" "myip" {
  url = "https://api.ipify.org"
}

data "aws_availability_zones" "available" {}


# Before deploing ec2 instance, we need to validate that the AMI exists.
# This data source fetches the AMI by its ID.
data "aws_ami" "default" {
  filter {
    name   = "image-id"
    values = [var.aws_ec2_ami_id]
  }
}