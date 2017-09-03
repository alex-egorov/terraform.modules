
output "lvm-init" {
  value = "${data.template_file.bitbucket-lvm.rendered}"
}

data "template_file" "bitbucket-lvm" {
  template = "${file("${path.module}/scripts/lvm.sh.tpl")}"
  vars {
    "device" = "${var.device}"
    "vgname" = "${var.vgname}"
    "lvname" = "${var.lvname}"
    "mountp" = "${var.mountp}"
  }
}
