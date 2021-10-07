output "public_ip" {
    value = "${aws_instance.NginxInstance.public_ip}"
}