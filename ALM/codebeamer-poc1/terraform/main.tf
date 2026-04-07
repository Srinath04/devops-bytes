################################################################################
# Codebeamer 22.10-SP11 on AWS — Terraform
# Region: ap-south-1 (Mumbai)
# Author: Srinath 
# Environment: personal learning environment
#
# Pre-requisites:
# AWS CLI configured
#
# USAGE:
#   1. cd into this folder
#   2. terraform init
#   3. terraform apply
#   4. Wait few mins, open URL printed in output
#   5. Run Setup Wizard (see runbook)
#
# TEARDOWN (avoid costs):
#   terraform destroy
################################################################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

################################################################################
# VARIABLES — Edit these only
################################################################################

variable "aws_region" {
  default = "ap-south-1"
}

variable "key_pair_name" {
  default = "" # Add your existing AWS EC2 key pair name here (not the .pem file, just the name) 
}

variable "your_ip" {
  description = "Your current IP with /32 — update this if your IP changes"
  default     = "" # Find your IP and add /32 at the end
}

variable "instance_type" {
  description = "t3.large = 8GB RAM (recommended). t3.medium = 4GB (slower but cheaper)"
  default     = "t3.large"
}

variable "postgres_password" {
  default = "" # Set a db password here 
}

variable "volume_size" {
  description = "Root EBS volume size in GB — 20GB is enough for poc"
  default     = 20
}

################################################################################
# PROVIDER
################################################################################

provider "aws" {
  region = var.aws_region
}

################################################################################
# DATA — Latest Ubuntu 22.04 LTS AMI (official Canonical)
################################################################################

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

################################################################################
# SECURITY GROUP
################################################################################

resource "aws_security_group" "codebeamer_sg" {
  name        = "codebeamer-sg"
  description = "Codebeamer ALM - SSH and Web UI"

  # SSH — your IP only
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.your_ip]
    description = "SSH from my IP"
  }

  # Codebeamer Web UI — your IP only
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.your_ip]
    description = "Codebeamer Web UI from my IP"
  }

  # All outbound allowed (needed for Docker pulls)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "codebeamer-sg"
    Purpose = "poc"
  }
}

################################################################################
# ELASTIC IP — Fixed IP, never changes on stop/start
################################################################################

resource "aws_eip" "codebeamer_eip" {
  instance = aws_instance.codebeamer.id
  domain   = "vpc"

  tags = {
    Name = "codebeamer-eip"
  }
}

################################################################################
# EC2 INSTANCE
################################################################################

resource "aws_instance" "codebeamer" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.codebeamer_sg.id]

  root_block_device {
    volume_size           = var.volume_size
    volume_type           = "gp3"     # faster and cheaper than gp2
    delete_on_termination = true
  }

  # Everything runs automatically on first boot
  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Log everything to a file you can check
    exec > /var/log/cb-setup.log 2>&1

    echo "=== Starting Codebeamer setup $(date) ==="

    # Update system
    apt-get update -y
    apt-get upgrade -y

    # Install Docker
    apt-get install -y docker.io curl unzip
    systemctl start docker
    systemctl enable docker

    # Add ubuntu user to docker group
    usermod -aG docker ubuntu

    # Install Docker Compose
    curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-linux-x86_64" \
      -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    echo "=== Docker installed ==="

    # Create Docker network
    docker network create cb-network

    # Start PostgreSQL 12
    docker run -d \
      --name cb-postgres \
      -e POSTGRES_USER=postgres \
      -e POSTGRES_PASSWORD=${var.postgres_password} \
      -e POSTGRES_DB=postgres \
      -v cb-pgdata:/var/lib/postgresql/data \
      --network cb-network \
      --restart unless-stopped \
      postgres:12

    echo "=== PostgreSQL started, waiting 20s ==="
    sleep 20

    # Start Codebeamer
    docker run -d \
      --name codebeamer \
      -p 8080:8080 \
      -v cb-data:/opt/codebeamer/repository \
      --network cb-network \
      --restart unless-stopped \
      intland/codebeamer:22.10-SP11

    echo "=== Codebeamer container started ==="
    echo "=== Setup complete $(date) ==="
    echo "=== Access at http://$(curl -s ifconfig.me):8080/cb in 5 mins ==="
  EOF

  tags = {
    Name    = "codebeamer-server"
    Purpose = "poc"
  }
}

################################################################################
# OUTPUTS — Printed after terraform apply completes
################################################################################

output "elastic_ip" {
  description = "Your fixed Elastic IP — use this always, never changes"
  value       = aws_eip.codebeamer_eip.public_ip
}

output "codebeamer_url" {
  description = "Open this in browser after few minutes"
  value       = "http://${aws_eip.codebeamer_eip.public_ip}:8080/cb"
}

output "ssh_command" {
  description = "SSH into your EC2"
  value       = "ssh -i /your/key/pair.pem ubuntu@${aws_eip.codebeamer_eip.public_ip}"
}

output "check_setup_logs" {
  description = "SSH in and run this to watch setup progress"
  value       = "tail -f /var/log/cb-setup.log"
}

output "update_your_ip" {
  description = "If your IP changes, run this to update security group"
  value       = "terraform apply -var='your_ip=NEW.IP.HERE/32'"
}

output "stop_ec2_command" {
  description = "Stop EC2 to save cost (EBS still charges)"
  value       = "aws ec2 stop-instances --instance-ids ${aws_instance.codebeamer.id} --region ap-south-1"
}

output "start_ec2_command" {
  description = "Start EC2 again — same Elastic IP, containers auto-start"
  value       = "aws ec2 start-instances --instance-ids ${aws_instance.codebeamer.id} --region ap-south-1"
}

output "destroy_everything" {
  description = "Tear down ALL resources when done — stops all charges"
  value       = "Run: terraform destroy"
}
