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
sudo docker pull jennykibiri/multicontainer-clientimage:latest
sudo docker run  -d -p 3000:3000 jennykibiri/multicontainer-clientimage:latest
EOF
  tags = {
    Name = "${var.env_prefix}-shecodes-web-server-1"
  }
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
sudo docker pull jennykibiri/multicontainer-clientimage
sudo docker run  -d -p 3000:3000 jennykibiri/multicontainer-clientimage
EOF
  tags = {
    Name = "${var.env_prefix}-shecodes-web-server-2"
  }
}

output "web-server1-public-ip" {
  value = aws_instance.web-server-1.public_ip
}

output "web-server2-public-ip" {
  value = aws_instance.web-server-2.public_ip
}
