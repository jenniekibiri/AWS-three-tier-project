
#web subnet 1
resource "aws_subnet" "web-subnet-1" {
  vpc_id                  = aws_vpc.shecodesafrica_vpc.id
  cidr_block              = var.web_subnet1_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = var.avail_zone1
  tags = {
    Name : "${var.env_prefix}-shecodes-web-subnet1"
  }

}
#web subnet 2
resource "aws_subnet" "web-subnet-2" {
  vpc_id                  = aws_vpc.shecodesafrica_vpc.id
  cidr_block              = var.web_subnet2_cidr_block
  availability_zone       = var.avail_zone2
  map_public_ip_on_launch = true
  tags = {
    Name : "${var.env_prefix}-shecodes-web-subnet2"
  }

}
