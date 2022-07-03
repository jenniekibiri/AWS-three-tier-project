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
variable "app_subnet1_cidr_block" {}
variable "app_subnet2_cidr_block" {}
variable "db_subnet1_cidr_block" {}
variable "db_subnet2_cidr_block" {}
variable "instance_type" {}
variable "public_key_location" {}
variable "jenkins_server" {}
variable "db_username" {}
variable "db_password" {}
  






# vpc 
resource "aws_vpc" "shecodesafrica_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name : "${var.env_prefix}-shecodes-vpc"
  }
}



// internet gateway to enable public subnet access to the internet
resource "aws_internet_gateway" "shecodes_igw" {
  vpc_id = aws_vpc.shecodesafrica_vpc.id
  tags = {
    Name = "${var.env_prefix}-shecodes-igw"
  }
}

