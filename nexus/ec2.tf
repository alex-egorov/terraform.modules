################################### INSTANCE  ##################################

resource "aws_instance" "nexus" {
 ami = "${var.ec2_ami_id}"
 instance_type = "${var.ec2_instance}"
 key_name = "${var.key_name}"

 subnet_id = "${var.ec2_subnet_id}"
 private_ip = "${var.ec2_private_ip}"

 iam_instance_profile = "${aws_iam_instance_profile.nexus.id}"
 vpc_security_group_ids = ["${var.ec2_security_groups}", "${aws_security_group.nexus.id}"]

 user_data  = "${data.template_cloudinit_config.nexus-config.rendered}"

 associate_public_ip_address = "${var.ec2_associate_public_ip}"
 disable_api_termination     = "${var.ec2_disable_api_termination}"

 monitoring  = true

 lifecycle {
   ignore_changes = ["user_data"]
 }

 root_block_device {
   delete_on_termination = true
   volume_type = "gp2"
   volume_size = "${var.ec2_ebs_root_size}"
 }

 tags {
     Name = "${var.prefix}-${var.name}"
     Terraform = "Terraform"
     Created   = "${var.owner}"
 }
}

output "nexus-instance" {
  value = "${aws_instance.nexus.private_ip}"
}

##################################  EXTRA VOLUMES ##############################

################################### EXTRA VOLUME ###############################
resource "aws_ebs_volume" "nexus_ebs_2" {
  availability_zone = "${aws_instance.nexus.availability_zone}"
  size              = "${var.ec2_ebs_storage_size}"

  tags {
    Name      = "${var.prefix}-${var.name}-ebs_2"
    Terraform = "Terraform"
    Created   = "${var.owner}"
  }
}

resource "aws_volume_attachment" "nexus_ebs_2_attach" {
  device_name   = "/dev/xvdb"
  volume_id     = "${aws_ebs_volume.nexus_ebs_2.id}"
  instance_id   = "${aws_instance.nexus.id}"
  force_detach  = true
  skip_destroy  = false   #!!! set to true in production
}

################################## CLOUD-INIT ##################################

module "lvm" {
  source  = "../lvm/"

  device = "/dev/xvdb"
  vgname = "data"
  lvname = "nexus"
  mountp = "${var.ec2_mount_point}"
}

module "common" {
  source  = "../common/"
}


data "template_cloudinit_config" "nexus-config" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "01-docker.sh"
    content_type = "text/x-shellscript"
    content      = "${module.common.docker-init}"
  }

  part {
    filename     = "02-lvm.sh"
    content_type = "text/x-shellscript"
    content      = "${module.lvm.lvm-init}"
  }

  part {
    filename     = "03-custom-metrics.sh"
    content_type = "text/x-shellscript"
    content      = "${module.common.custom-metrics}"
  }

  part {
    filename     = "04-nexus-install.sh"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.nexus-install.rendered}"
  }
}

data "template_file" "nexus-install" {
    template = "${file("${path.module}/scripts/nexus-install.sh.tpl")}"
    vars {
      "version"         = "${var.ec2_version}"
      "hostname"        = "${var.ec2_hostname}"
      "mountp"          = "${var.ec2_mount_point}"
      "java_max_mem"    = "${var.java_max_mem}"
      "java_min_mem"    = "${var.java_min_mem}"
      "extra_java_opts" = "${var.extra_java_opts}"
      "context_path"    = "${var.context_path}"
    }
}
