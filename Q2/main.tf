provider "aws" {
	region = "us-east-1"
}
module "ec2_module" {
	source = "./ec2Module"
}
module "iam_module" {
	source = "./iamModule"
}










