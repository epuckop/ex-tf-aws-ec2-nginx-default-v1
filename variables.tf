variable "aws_region" {
  description = "The AWS region to deploy resources in, default is il-central-1"
  type        = string
}

variable "owner" {
  description = "The owner of the resources, used for tagging"
  type        = string
}

variable "environment" {
  description = "The environment for the resources, used for tagging"
  type        = string
  default     = "tst"

  validation {
    condition     = can(regex("^(dev|tst|qa|uat|stg|prod)$", var.environment))
    error_message = "Environment must be one of: dev, tst, qa, uat, stg, prod"
  }
}

variable "project" {
  description = "The project name for the resources, used for tagging"
  type        = string
  default     = "none"

  validation {
    condition     = length(var.project) > 0 && length(var.project) <= 16 && can(regex("^[a-z0-9]+$", var.project))
    error_message = "Project must be 1-16 characters. Allowed: lowercase letters (a-z) and numbers (0-9) only. No spaces, uppercase, or special characters. This variable is used for naming resources."
  }
}

variable "managed_by" {
  description = "The entity managing the resources, used for tagging"
  type        = string
  default     = "terraform"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.vpc_cidr_block, 0))
    error_message = "The value must be a valid CIDR notation (e.g., 10.0.0.0/16)."
  }
}

variable "aws_ec2_ami_id" {
  description = "The ID of the AWS AMI to use for the EC2 instance"
  type        = string

  validation {
    condition     = can(regex("^ami-[a-z0-9]+$", var.aws_ec2_ami_id))
    error_message = "AMI ID must start with 'ami-' followed by alphanumeric characters."
  }
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "The type of EC2 instance to create. Default is t3.micro."
}