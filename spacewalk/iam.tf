################################# IAM PROFILE ##################################
resource "aws_iam_instance_profile" "spacewalk" {
    name = "${var.name}-spacewalk"
    roles = ["${aws_iam_role.spacewalk.name}"]
}

resource "aws_iam_role" "spacewalk" {
    name = "${var.name}-spacewalk"
    path = "/"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}
