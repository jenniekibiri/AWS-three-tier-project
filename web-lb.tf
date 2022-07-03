
//attach load balancer to target group
resource "aws_lb_target_group_attachment" "external-elb1" {
  target_group_arn = aws_lb_target_group.external-elb.arn
  target_id        = aws_instance.web-server-1.id
  port             = 3000

  depends_on = [
    aws_instance.web-server-1,
  ]
}

resource "aws_lb_target_group_attachment" "external-elb2" {
  target_group_arn = aws_lb_target_group.external-elb.arn
  target_id        = aws_instance.web-server-2.id
  port             =  3000

  depends_on = [
    aws_instance.web-server-2,
  ]
}


resource "aws_lb" "external-elb" {
  name               = "${var.env_prefix}-shecodes-external-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.web-subnet-1.id, aws_subnet.web-subnet-2.id]
  security_groups    = [aws_security_group.loadbalancer-sg.id]
}

//attach load balancer to web servers
resource "aws_lb_target_group" "external-elb" {
  name     = "ALB-TG"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.shecodesafrica_vpc.id
}

//listens on port 80 and redirects to target group
resource "aws_lb_listener" "external-elb" {
  load_balancer_arn = aws_lb.external-elb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external-elb.arn
  }
}
