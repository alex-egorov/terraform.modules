output "instance_ip" {
  value = "${aws_instance.nexus.private_ip}"
}

output "instance_id" {
  value = "${aws_instance.nexus.id}"
}

output "availability_zone" {
  value = "${aws_instance.nexus.availability_zone}"
}
