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
variable "instance_type" {}
variable "public_key_location" {}
variable "jenkins_server" {}




# vpc 
resource "aws_vpc" "shecodesafrica_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name : "${var.env_prefix}-shecodes-vpc"
  }
}

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

// internet gateway to enable public subnet access to the internet
resource "aws_internet_gateway" "shecodes_igw" {
  vpc_id = aws_vpc.shecodesafrica_vpc.id
  tags = {
    Name = "${var.env_prefix}-shecodes-igw"
  }
}

// route table for the internet gateway
resource "aws_route_table" "web-rtb" {
  #which VPC this route table belongs to
  vpc_id = aws_vpc.shecodesafrica_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.shecodes_igw.id

  }
  tags = {
    Name : "${var.env_prefix}-web-rtb"
  }

}

resource "aws_route_table_association" "a-rtb-web-subnet1" {
  subnet_id      = aws_subnet.web-subnet-1.id
  route_table_id = aws_route_table.web-rtb.id

}


resource "aws_route_table_association" "a-rtb-web-subnet2" {
  subnet_id      = aws_subnet.web-subnet-2.id
  route_table_id = aws_route_table.web-rtb.id

}

//ec2 instances for the web servers

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-linux-image.id
}
resource "aws_key_pair" "ssh-key" {
  key_name   = "server-key"
  public_key = file(var.public_key_location)
}



resource "aws_instance" "web-server-1" {
  ami                         = data.aws_ami.latest-amazon-linux-image.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.web-subnet-1.id
  availability_zone           = var.avail_zone1
  key_name                    = aws_key_pair.ssh-key.key_name
  vpc_security_group_ids      = [aws_security_group.webserver-sg.id]
  associate_public_ip_address = true
  user_data                   = <<EOF
#!/bin/bash
sudo yum update -y && sudo yum install -y docker
sudo systemctl start docker 
sudo usermod -aG docker ec2-user
docker run -p 8080:80 nginx
EOF
  tags = {
    Name = "${var.env_prefix}-shecodes-web-server-1"
  }
}

output "web-server1-public-ip" {
  value = aws_instance.web-server-1.public_ip
}

resource "aws_instance" "web-server-2" {
  ami                         = data.aws_ami.latest-amazon-linux-image.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.web-subnet-2.id
  availability_zone           = var.avail_zone2
  key_name                    = aws_key_pair.ssh-key.key_name
  vpc_security_group_ids      = [aws_security_group.webserver-sg.id]
  associate_public_ip_address = true
  user_data                   = <<EOF
#!/bin/bash
sudo yum update -y && sudo yum install -y docker
sudo systemctl start docker 
sudo usermod -aG docker ec2-user
docker run -p 8080:80 nginx
EOF
  tags = {
    Name = "${var.env_prefix}-shecodes-web-server-2"
  }
}

output "web-server2-public-ip" {
  value = aws_instance.web-server-2.public_ip
}


//web server security group
resource "aws_security_group" "web-sg" {
  name        = "web-sg"
  vpc_id      = aws_vpc.shecodesafrica_vpc.id
  description = "Web server security group"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip, var.jenkins_server]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = "0"
    to_port         = "0"
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name = "${var.env_prefix}-shecodes-web-sg"
  }
}


# Create Web Server Security Group
resource "aws_security_group" "webserver-sg" {
  name        = "Webserver-SG"
  description = "Allow inbound traffic from ALB"
  vpc_id      = aws_vpc.shecodesafrica_vpc.id

  ingress {
    description     = "Allow traffic from web layer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web-sg.id]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip, var.jenkins_server]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_prefix}-shecodes-webserver-sg"
  }
}


//load balancer
resource "aws_lb" "external-elb" {
  name               = "${var.env_prefix}-shecodes-external-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.web-subnet-1.id, aws_subnet.web-subnet-2.id]
  security_groups    = [aws_security_group.web-sg.id]
}

//attach load balancer to web servers
resource "aws_lb_target_group" "external-elb" {
  name     = "ALB-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.shecodesafrica_vpc.id
}


//attach load balancer to target group
resource "aws_lb_target_group_attachment" "external-elb1" {
  target_group_arn = aws_lb_target_group.external-elb.arn
  target_id        = aws_instance.web-server-1.id
  port             = 80

  depends_on = [
    aws_instance.web-server-1,
  ]
}

resource "aws_lb_target_group_attachment" "external-elb2" {
  target_group_arn = aws_lb_target_group.external-elb.arn
  target_id        = aws_instance.web-server-2.id
  port             = 80

  depends_on = [
    aws_instance.web-server-2,
  ]
}


//listens on port 80 and redirects to target group
resource "aws_lb_listener" "external-elb" {
  load_balancer_arn = aws_lb.external-elb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external-elb.arn
  }
}

/* application tier */
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

//elastic ip for nat gateway
resource "aws_eip" "app-nat-eip" {
  vpc        = true
  depends_on = [
    aws_internet_gateway.shecodes_igw,
  ]

  
}

//nat gateway -app-nat-gateway
resource "aws_nat_gateway" "app-nat-gateway" {
  subnet_id     = aws_subnet.web-subnet-2.id
  allocation_id = aws_eip.app-nat-eip.id
  tags = {
    Name = "${var.env_prefix}-shecodes-app-nat-gateway"
  }
}

//route-table -shecodes-app-rtb
resource "aws_route_table" "app-rtb" {
  vpc_id = aws_vpc.shecodesafrica_vpc.id
  route  {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.app-nat-gateway.id
  }
  tags = {
    Name : "${var.env_prefix}-shecodes-app-rtb"
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


resource "aws_instance" "app-server-1" {
  ami                         = data.aws_ami.latest-amazon-linux-image.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.app-subnet-1.id
  availability_zone           = var.avail_zone1
  key_name                    = aws_key_pair.ssh-key.key_name
  vpc_security_group_ids      = [aws_security_group.appserver-sg.id]
  associate_public_ip_address = true
  user_data                   = <<EOF
#!/bin/bash
sudo yum update -y && sudo yum install -y docker
sudo systemctl start docker 
sudo usermod -aG docker ec2-user
docker run -p 8080:80 nginx
EOF
  tags = {
    Name = "${var.env_prefix}-shecodes-app-server-1"
  }
}
resource "aws_instance" "app-server-2" {
  ami                         = data.aws_ami.latest-amazon-linux-image.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.app-subnet-2.id
  availability_zone           = var.avail_zone2
  key_name                    = aws_key_pair.ssh-key.key_name
  vpc_security_group_ids      = [aws_security_group.appserver-sg.id]
  associate_public_ip_address = true
  user_data                   = <<EOF
#!/bin/bash
sudo yum update -y && sudo yum install -y docker
sudo systemctl start docker 
sudo usermod -aG docker ec2-user
docker run -p 8080:80 nginx
EOF
  tags = {
    Name = "${var.env_prefix}-shecodes-app-server-2"
  }
}


//security-group -shecodes-app-sg

resource "aws_security_group" "app-sg" {
  name        = "app-SG"
  description = "Allow inbound traffic from ALB"
  vpc_id      = aws_vpc.shecodesafrica_vpc.id


  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip, var.jenkins_server]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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


resource "aws_security_group" "appserver-sg" {
  name        = "appserver-SG"
  description = "Allow inbound traffic from ALB"
  vpc_id      = aws_vpc.shecodesafrica_vpc.id

  ingress {
    description     = "Allow traffic from web layer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.app-sg.id]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip, var.jenkins_server]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_prefix}-shecodes-appserver-sg"
  }
}


//load-balancer -shecodes-app-elb
resource "aws_lb" "internal-elb" {
  name               = "${var.env_prefix}-shecodes-internal-lb"
  internal           = true
  load_balancer_type = "application"
  subnets            = [aws_subnet.app-subnet-1.id, aws_subnet.app-subnet-2.id]
  security_groups    = [aws_security_group.app-sg.id]
}
//target-group -shecodes-app-tg
resource "aws_lb_target_group" "internal-elb" {
  name     = "ILB-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.shecodesafrica_vpc.id
}



//target-group-attachment -shecodes-app-tg-attachment
resource "aws_lb_target_group_attachment" "internal-elb1" {
  target_group_arn = aws_lb_target_group.internal-elb.arn
  target_id        = aws_instance.app-server-1.id
  port             = 80

  depends_on = [
    aws_instance.app-server-1,
  ]
}
resource "aws_lb_target_group_attachment" "internal-elb2" {
  target_group_arn = aws_lb_target_group.internal-elb.arn
  target_id        = aws_instance.app-server-2.id
  port             = 80

  depends_on = [
    aws_instance.app-server-2,
  ]
}


//listens on port 80 and redirects to target group
resource "aws_lb_listener" "internal-elb" {
  load_balancer_arn = aws_lb.internal-elb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal-elb.arn
  }
}

