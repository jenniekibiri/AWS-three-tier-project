
resource "aws_security_group" "app-loadbalancer-sg" {
  name        = "loadbalancer-SG"
  description = "Allow inbound traffic from ALB"
  vpc_id      = aws_vpc.shecodesafrica_vpc.id


  ingress {
    description     = "HTTP from anywhere"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.webserver-sg.id]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_prefix}-shecodes-app-sg"
  }
}

