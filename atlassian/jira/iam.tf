################################# IAM PROFILE ##################################
resource "aws_iam_instance_profile" "jira" {
    name = "${var.prefix}-${var.name}"
    roles = ["${aws_iam_role.jira.name}"]
}

resource "aws_iam_role" "jira" {
    name = "${var.prefix}-${var.name}"
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
