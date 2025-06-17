# AWS EC2 NGINX Deployment with Terraform and Ansible

This project automates the deployment of an NGINX web server on AWS EC2 using Terraform for infrastructure provisioning and Ansible for configuration management.

## Prerequisites

- AWS Account
- Terraform >= 1.0.0
- Ansible >= 2.9
- AWS CLI configured with appropriate credentials
- SSH client

## Features

- This deployment do not use remote state.
- Fully automated deployment using Terraform and Ansible
- Secure infrastructure setup with:
  - Custom VPC
  - Public subnet
  - Internet Gateway
  - Security Group rules for HTTP/HTTPS access
  - SSH key pair generation
- NGINX installation and configuration using Ansible
- Amazon Linux 2023 as the base OS

## Infrastructure Components

- VPC with custom CIDR block
- Internet Gateway for public internet access
- Public subnet for the EC2 instance
- Security Group allowing:
  - HTTP (80)
  - HTTPS (443)
  - SSH (22)
- EC2 instance running Amazon Linux 2023
- SSH key pair for secure access

## Quick Start

1. Clone this repository to your local machine.

2. Create `terraform.auto.tfvars` file with your values, example can be found in `terraform.auto.tfvars.ex.txt` file.

3. Run Terraform.


## Requirements

| Name      | Version |
|-----------|---------|
| terraform | >= 1.0  |
| aws       | >= 5.0  |
| ansible   | >= 2.9  |


## Clean Up

To remove all resources:

```bash
terraform destroy
```

## Notes

- The EC2 instance uses Amazon Linux 2023 for optimal compatibility
- Security Group is configured with basic rules for web server access
- Infrastructure is designed for testing/development purposes
- All AWS resources will be tagged with owner and environment tags

## License

This project is licensed under the terms specified in the LICENSE file.
