# variables.tf

# AWS Configuration
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"

  validation {
    condition = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region must be in the format like 'us-east-1'."
  }
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "default"
}

# EC2 Configuration
variable "instance_type" {
  description = "EC2 instance type (t2.micro is free tier eligible)"
  type        = string
  default     = "t2.micro"

  validation {
    condition = contains([
      "t2.micro", "t2.small", "t2.medium", "t2.large",
      "t3.micro", "t3.small", "t3.medium", "t3.large"
    ], var.instance_type)
    error_message = "Instance type must be a valid t2 or t3 type."
  }
}

variable "key_pair_name" {
  description = "Name of the AWS Key Pair for SSH access (must exist in your AWS account)"
  type        = string
  
  validation {
    condition     = length(var.key_pair_name) > 0
    error_message = "Key pair name cannot be empty. Please specify an existing AWS Key Pair."
  }
}

variable "ami_id" {
  description = "AMI ID to use for the instance (leave empty to use latest Amazon Linux 2)"
  type        = string
  default     = ""
}

# Network Configuration
variable "allowed_cidr" {
  description = "CIDR block allowed for SSH access (use your IP/32 for security)"
  type        = string
  default     = "0.0.0.0/0"

  validation {
    condition = can(cidrhost(var.allowed_cidr, 0))
    error_message = "The allowed_cidr must be a valid CIDR block."
  }
}

variable "enable_http" {
  description = "Enable HTTP access on port 80"
  type        = bool
  default     = true
}

variable "enable_https" {
  description = "Enable HTTPS access on port 443"
  type        = bool
  default     = false
}

# Instance Configuration
variable "instance_name" {
  description = "Name for the EC2 instance"
  type        = string
  default     = "terraform-ec2-instance"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring for the instance"
  type        = bool
  default     = false
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 8

  validation {
    condition = var.root_volume_size >= 8 && var.root_volume_size <= 100
    error_message = "Root volume size must be between 8 and 100 GB."
  }
}

# Project Information
variable "project_name" {
  description = "Name of the project for resource tagging"
  type        = string
  default     = "terraform-learning"
}

variable "owner" {
  description = "Owner of the resources (for tagging purposes)"
  type        = string
  default     = "terraform-user"
}

# User Data Script
variable "user_data_script" {
  description = "User data script to run on instance launch"
  type        = string
  default     = ""
}
