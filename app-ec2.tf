
resource "aws_instance" "app-server-1" {
  ami                         = data.aws_ami.latest-amazon-linux-image.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.app-subnet-1.id
  availability_zone           = var.avail_zone1
  key_name                    = aws_key_pair.ssh-key.key_name
  vpc_security_group_ids      = [aws_security_group.appserver-sg.id]
    depends_on = [
    aws_nat_gateway.app-nat-gateway
  ]
  user_data                   = <<EOF
#!/bin/bash
sudo yum update -y && sudo yum install -y docker
sudo systemctl start docker 
sudo usermod -aG docker ec2-user
sudo docker pull jennykibiri/multicontainer-serverimage:latest
sudo docker run -p 8000:3000 jennykibiri/multicontainer-serverimage:latest

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
  depends_on = [
    aws_nat_gateway.app-nat-gateway
  ]
  user_data                   = <<EOF
#!/bin/bash
sudo yum update -y && sudo yum install -y docker
sudo systemctl start docker 
sudo usermod -aG docker ec2-user
sudo docker pull jennykibiri/multicontainer-serverimage:latest
sudo docker run -d -p 8000:3000 jennykibiri/multicontainer-serverimage:latest
EOF
  tags = {
    Name = "${var.env_prefix}-shecodes-app-server-2"
  }
}
