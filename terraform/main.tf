terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  required_version = ">= 1.0.0"
}

provider "aws" {
  region = var.region
}

  resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "vpc"
  }
}

resource "aws_subnet" "subnet" {
  count = 2
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)
  availability_zone       = element(["us-west-2a", "us-west-2b"], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-${count.index}"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "route" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "route"
  }
}



resource "aws_route_table_association" "public_subnet" {
  count          = 1
  subnet_id      = aws_subnet.subnet[count.index].id
  route_table_id = aws_route_table.route.id
}



resource "aws_security_group" "sg" {
  name        = "sg"
  description = "eks security group"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "iam_role" {
  name = "stage-eks-worker-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}
