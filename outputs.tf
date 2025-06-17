# output "private_key_pem" {
#   # This output is sensitive because it contains the private key
#   value       = tls_private_key.default.private_key_pem
#   description = "The private key in PEM format for the EC2 SSH key pair"
#   sensitive   = true
# }

# output "public_key_ec2ssh" {
#   value       = local.key_pairs_list
#   description = "Value of the EC2 SSH key pair, including the key name and public key"
# }

output "myip" {
  value       = data.http.myip.response_body
  description = "The public IP address of the machine running this Terraform configuration"
}

output "serverip" {
  value       = aws_eip.default.public_ip
  description = "The public IP address of the EC2 instance"
}

# output "azs" {
#   value = data.aws_availability_zones.available.names
# }

# output "aws_ami" {
#   value       = data.aws_ami.default
#   description = "The name of the AWS AMI resource"
# }