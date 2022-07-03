//web server security group
resource "aws_security_group" "loadbalancer-sg" {
  name        = "loadbalancer"
  vpc_id      = aws_vpc.shecodesafrica_vpc.id
  description = "Web server security group"


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name = "${var.env_prefix}-shecodes-loadbalancer-sg"
  }
}
