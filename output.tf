output "public_ip" {
    value = "${aws_instance.NginxInstance.public_ip}"
}

output "DNS" {
    
    value="${aws_instance.NginxInstance-ami.public_dns}"
}
output "ELB_DNS" {
    
    value="${aws_elb.nginx.dns_name}"
}