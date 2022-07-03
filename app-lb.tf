//load-balancer -shecodes-app-elb
resource "aws_lb" "internal-elb" {
  name               = "${var.env_prefix}-shecodes-internal-lb"
  internal           = true
  load_balancer_type = "application"
  subnets            = [aws_subnet.app-subnet-1.id, aws_subnet.app-subnet-2.id]
  security_groups    = [aws_security_group.loadbalancer-sg.id]
  enable_deletion_protection = false
}


//listens on port 80 and redirects to target group
resource "aws_lb_listener" "internal-elb" {
  load_balancer_arn = aws_lb.internal-elb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal-elb.arn
  }
}

//target-group -shecodes-app-tg
resource "aws_lb_target_group" "internal-elb" {
  name     = "ILB-TG"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_vpc.shecodesafrica_vpc.id
}

//target-group-attachment -shecodes-app-tg-attachment
resource "aws_lb_target_group_attachment" "internal-elb1" {
  target_group_arn = aws_lb_target_group.internal-elb.arn
  target_id        = aws_instance.app-server-1.id
  port             = 8000

  depends_on = [
    aws_instance.app-server-1,
  ]
}
resource "aws_lb_target_group_attachment" "internal-elb2" {
  target_group_arn = aws_lb_target_group.internal-elb.arn
  target_id        = aws_instance.app-server-2.id
  port             = 8000

  depends_on = [
    aws_instance.app-server-2,
  ]
}
