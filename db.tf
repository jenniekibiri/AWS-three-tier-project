
#db tier
//subnet
resource "aws_subnet" "db-subnet-1" {
  vpc_id            = aws_vpc.shecodesafrica_vpc.id
  cidr_block        = var.db_subnet1_cidr_block
  availability_zone = var.avail_zone1
  tags = {
    Name = "${var.env_prefix}-shecodes-db-subnet-1"
  }
}
resource "aws_subnet" "db-subnet-2" {
  vpc_id            = aws_vpc.shecodesafrica_vpc.id
  cidr_block        = var.db_subnet2_cidr_block
  availability_zone = var.avail_zone2
  tags = {
    Name = "${var.env_prefix}-shecodes-db-subnet-2"
  }
}

//sg -shecodes-db-sg
resource "aws_security_group" "db-sg" {
  name        = "db-SG"
  description = "Allow inbound traffic from ALB"
  vpc_id      = aws_vpc.shecodesafrica_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.webserver-sg.id]

  }
}

//subneg group -shecodes-db-subnet-group
resource "aws_db_subnet_group" "db-subnet-group" {
  name        = "db-subnet-group"
  description = "db subnet group"
  subnet_ids = [aws_subnet.db-subnet-1.id, aws_subnet.db-subnet-2.id]
}

//instance -shecodes-db-instance
resource "aws_db_instance" "default" {
  identifier             = "${var.env_prefix}-shecodes-db-instance"
  db_subnet_group_name   = aws_db_subnet_group.db-subnet-group.id
  instance_class         = "db.t2.micro"
  engine                 = "mysql"
  engine_version         = "5.7"
  username               = var.db_username
  password               = var.db_password
  vpc_security_group_ids = [aws_security_group.db-sg.id, aws_security_group.webserver-sg.id]

  multi_az            = true
  allocated_storage   = 5
  skip_final_snapshot = true
  tags = {
    Name = "${var.env_prefix}-shecodes-db-instance"
  }
}
