output "system" {
  value = "${file("${path.module}/scripts/system.sh")}"
}

output "docker-init" {
  value = "${file("${path.module}/scripts/docker-init.sh")}"
}

output "openvpn-init" {
  value = "${file("${path.module}/scripts/openvpn-init.sh")}"
}

output "custom-metrics" {
  value = "${file("${path.module}/scripts/custom-metrics.sh")}"
}
