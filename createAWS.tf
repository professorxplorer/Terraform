#Create security group with firewall rules
resource "aws_security_group" "security_Nginxport" {
  name        = "security_jenkins_port"
  description = "security group for jenkins"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 # outbound from jenkis server
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags= {
    Name = "security_jenkins_port"
  }
}

resource "aws_instance" "NginxInstance" {
  ami           = "ami-09e67e426f25ce0d7"
  # count =1
  key_name = "PXT"
  instance_type = "t2.micro"
  security_groups= [ "security_Nginx_port"]
  tags= {
    Name = "NginxInstance"
     user_data = <<-EOF
      #!/bin/sh
      sudo apt-get update
      sudo apt-get upgrade -y
      sudo apt install nginx -y
      sudo ufw allow 'Nginx HTTP'
      sudo systemctl start nginx
      sudo systemctl enable nginx
      sudo chown -R $USER:$USER /var/www/html
      sudo echo "<html><body><h1>Hello from Webserver at instance id `curl http://169.254.169.254/latest/meta-data/instance-id` </h1></body></html>" > /var/www/html/index.html
      sudo systemctl restart nginx
      sudo shutdown
      EOF
  }
}

#Now Creating AMI from Above Instance

resource  "aws_ami_from_instance" "tNginxInstance" {
    name               = "NginxInstance"
    source_instance_id = "${aws_instance.NginxInstance.id}"

  depends_on = [
      aws_instance.NginxInstance,
      ]

  tags = {
      Name = "NginxInstance-ami"
  }

}

#Run  new 

resource "aws_instance" "NginxInstance-ami" {
  ami  = aws_ami_from_instance.tNginxInstance.id
  # count =1
  key_name = "PXT"
  instance_type = "t2.micro"
  security_groups= [aws_security_group.security_Nginxport.id]
  tags= {
    Name = "NginxInstance"
     user_data = <<-EOF
      #!/bin/sh
      sudo apt-get update
      EOF
  }
}
