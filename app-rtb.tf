//route-table -shecodes-app-rtb
resource "aws_route_table" "app-rtb" {
  vpc_id         = aws_vpc.shecodesafrica_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.app-nat-gateway.id
  }

  tags = {
    Name : "${var.env_prefix}-app-rtb"
  }
}


//route-table-association -shecodes-app-rtb-assoc
resource "aws_route_table_association" "a-rtb-app-subnet-1" {
  subnet_id      = aws_subnet.app-subnet-1.id
  route_table_id = aws_route_table.app-rtb.id
}


resource "aws_route_table_association" "a-rtb-app-subnet-2" {
  subnet_id      = aws_subnet.app-subnet-2.id
  route_table_id = aws_route_table.app-rtb.id
}
