//elastic ip for nat gateway
resource "aws_eip" "app-nat-eip" {
  vpc = true
  depends_on = [
    aws_internet_gateway.shecodes_igw,
  ]
}

//nat gateway -app-nat-gateway
resource "aws_nat_gateway" "app-nat-gateway" {
  subnet_id     = aws_subnet.web-subnet-2.id
  allocation_id = aws_eip.app-nat-eip.id
  depends_on = [aws_internet_gateway.shecodes_igw]
  tags = {
    Name = "${var.env_prefix}-shecodes-app-nat-gateway"
  }
}

