provider "aws" {
  region = "us-east-1"
}

//variables
variable "my_ip" {}
variable "env_prefix" {}
variable "vpc_cidr_block" {}
variable "avail_zone1" {}
variable "avail_zone2" {}
variable "web_subnet1_cidr_block" {}
variable "web_subnet2_cidr_block" {}
variable "instance_type" {}
variable "public_key_location" {}





# vpc 
resource "aws_vpc" "shecodesafrica_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name : "${var.env_prefix}-shecodes-vpc"
  }
}

#web subnet 1
resource "aws_subnet" "web-subnet-1" {
  vpc_id            = aws_vpc.shecodesafrica_vpc.id
  cidr_block        = var.web_subnet1_cidr_block
  availability_zone = var.avail_zone1
  tags = {
    Name : "${var.env_prefix}-shecodes-web-subnet1"
  }

}
#web subnet 2
resource "aws_subnet" "web-subnet-2" {
  vpc_id            = aws_vpc.shecodesafrica_vpc.id
  cidr_block        = var.web_subnet2_cidr_block
  availability_zone = var.avail_zone2
  tags = {
    Name : "${var.env_prefix}-shecodes-web-subnet2"
  }

}

// internet gateway to enable public subnet access to the internet
resource "aws_internet_gateway" "shecodes_igw" {
  vpc_id = aws_vpc.shecodesafrica_vpc.id
  tags = {
    Name = "${var.env_prefix}-shecodes-igw"
  }
}
// route table for the internet gateway



resource "aws_route_table" "web-rtb" {
  #which VPC this route table belongs to
  vpc_id = aws_vpc.shecodesafrica_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.shecodes_igw.id

  }
  tags = {
    Name : "${var.env_prefix}-web-rtb"
  }

}

resource "aws_route_table_association" "a-rtb-web-subnet1" {
  subnet_id      = aws_subnet.web-subnet-1.id
  route_table_id = aws_route_table.web-rtb.id

}


resource "aws_route_table_association" "a-rtb-web-subnet2" {
  subnet_id      = aws_subnet.web-subnet-2.id
  route_table_id = aws_route_table.web-rtb.id

}

//ec2 instances for the web servers

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-linux-image.id
}
resource "aws_key_pair" "ssh-key" {
  key_name   = "server-key"
  public_key = file(var.public_key_location)
}



resource "aws_instance" "web-server-1" {
  ami                         = data.aws_ami.latest-amazon-linux-image.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.web-subnet-1.id
  availability_zone           = var.avail_zone1
  key_name                    = aws_key_pair.ssh-key.key_name
  associate_public_ip_address = true
  user_data = <<EOF
#!/bin/bash
sudo yum update -y && sudo yum install -y docker
sudo systemctl start docker 
sudo usermod -aG docker ec2-user
docker run -p 8080:80 nginx
EOF
  tags = {
    Name = "${var.env_prefix}-shecodes-web-server-1"
  }
}

output "web-server1-public-ip" {
  value = aws_instance.web-server-1.public_ip
}

resource "aws_instance" "web-server-2" {
  ami                         = data.aws_ami.latest-amazon-linux-image.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.web-subnet-2.id
  availability_zone           = var.avail_zone2
  key_name                    = aws_key_pair.ssh-key.key_name
  associate_public_ip_address = true
  user_data = <<EOF
#!/bin/bash
sudo yum update -y && sudo yum install -y docker
sudo systemctl start docker 
sudo usermod -aG docker ec2-user
docker run -p 8080:80 nginx
EOF
  tags = {
    Name = "${var.env_prefix}-shecodes-web-server-2"
  }
}

output "web-server2-public-ip" {
  value = aws_instance.web-server-2.public_ip
}
