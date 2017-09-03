output "instance_ip" {
  value = "${aws_instance.bastion.private_ip}"
}

output "instance_id" {
  value = "${aws_instance.bastion.id}"
}

output "endpoint" {
  value = "${aws_instance.bastion.public_ip}"
}
