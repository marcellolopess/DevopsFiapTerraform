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
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Necessário para o apt-get funcionar e acesso geral à internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Cria uma instância EC2 com Apache rodando na porta 8080
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
    sed -i -e 's/80/8080/' /etc/apache2/ports.conf
    echo '<style> body {background-color: blue;}</style><img src="https://postech.fiap.com.br/imgs/fiap-plus-alura/fiap_alura.png">' > /var/www/html/index.html
    systemctl restart apache2
  EOF

  tags = {
    Name = "fiap-web"
  }
}
