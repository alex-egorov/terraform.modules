output "db_endpoint" {
  value = "${aws_db_instance.confluence.endpoint}"
}

output "instance_ip" {
  value = "${aws_instance.confluence.private_ip}"
}

output "instance_id" {
  value = "${aws_instance.confluence.id}"
}
