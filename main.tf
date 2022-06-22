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



# vpc 
resource "aws_vpc" "shecodesafrica_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name : "${var.env_prefix}-vpc"
  }
}

#web subnet 1
resource "aws_subnet" "web-subnet-1" {
  vpc_id            = aws_vpc.shecodesafrica_vpc.id
  cidr_block        = var.web_subnet1_cidr_block
  availability_zone = var.avail_zone1
  tags = {
    Name : "${var.env_prefix}-web-subnet1"
  }

}
#web subnet 2
resource "aws_subnet" "web-subnet-2" {
  vpc_id            = aws_vpc.shecodesafrica_vpc.id
  cidr_block        = var.web_subnet2_cidr_block
  availability_zone = var.avail_zone2
  tags = {
    Name : "${var.env_prefix}-web-subnet2"
  }

}
