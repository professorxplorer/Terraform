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

 # outbound from jenkins server
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags= {
    Name = var.ec2SecurityGroup
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
      Name = var.NginxInstance-ami
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



#EC2 Load Balancer
resource "aws_elb" "nginx" {
  name               = "nginx-elb"
  availability_zones = ["us-east-1a"]

##  access_logs {
  ##  bucket        = "nginx-acces-elb"
    ##interval      = 60
 #3 }

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }


  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  instances                   = [aws_instance.NginxInstance-ami.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = var.terraform-elb
  }
}

