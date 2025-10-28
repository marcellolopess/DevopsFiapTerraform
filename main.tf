# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0
# Fiap MBA SCJ

terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }

  # Caso deseje usar Terraform Cloud, descomente e ajuste:
  # cloud {
  #   organization = "DevopsFiap"
  #
  #   workspaces {
  #     name = "gh-actions"
  #   }
  # }
}

provider "aws" {
  region = "us-east-1"
}

# Gera um identificador aleatório para nomear recursos
resource "random_pet" "sg" {}

# Busca a AMI mais recente do Ubuntu 20.04
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Cria o grupo de segurança
resource "aws_security_group" "web_sg" {
  name = "${random_pet.sg.id}-sg"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blo_
