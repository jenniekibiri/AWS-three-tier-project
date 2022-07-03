# #!/bin/sh
# sudo yum update -y && sudo yum install -y docker
# sudo systemctl start docker 
# sudo usermod -aG docker ec2-user
# docker run -d --name hopeful_ritchie --network webserver-network -p 3000:80 nginx
# docker exec -it hopeful_ritchie bash  cp default.conf /etc/nginx/conf.d/default.conf
# sudo systemctl restart nginx
# sudo docker pull jennykibiri/multicontainer-clientimage:latest
# sudo docker run  -d --name multicontainer-client --network webserver-network -p 3001:3000 jennykibiri/multicontainer-clientimage:latest