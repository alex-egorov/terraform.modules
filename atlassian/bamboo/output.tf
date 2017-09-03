output "db_endpoint" {
  value = "${aws_db_instance.bamboo.endpoint}"
}

output "instance_ip" {
  value = "${aws_instance.bamboo.private_ip}"
}

output "instance_id" {
  value = "${aws_instance.bamboo.id}"
}
