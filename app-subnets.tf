/* -------------------------------------application tier ------------------------------------------------------------------*/
//subnet-1 -app-subnet-1
resource "aws_subnet" "app-subnet-1" {
  vpc_id                  = aws_vpc.shecodesafrica_vpc.id
  cidr_block              = var.app_subnet1_cidr_block
  availability_zone       = var.avail_zone1
  map_public_ip_on_launch = false
  tags = {
    Name : "${var.env_prefix}-shecodes-app-subnet1"
  }

}

//subnet-2 -app-subnet-2

resource "aws_subnet" "app-subnet-2" {
  vpc_id                  = aws_vpc.shecodesafrica_vpc.id
  cidr_block              = var.app_subnet2_cidr_block
  availability_zone       = var.avail_zone2
  map_public_ip_on_launch = false
  tags = {
    Name : "${var.env_prefix}-shecodes-app-subnet2"
  }
}