resource "aws_instance" "custom-ami" {
	ami = "ami-4283613821bb049f"
	instance_type = "t2.micro"
	tags= {
	Name= "iaac-module"
	}
}