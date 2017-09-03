resource "aws_iam_role_policy" "lambda_ebs_backup_policy" {

  name = "lambda_ebs_backup_policy"
  role = "${aws_iam_role.iam_for_lambda_backup_ebs.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "ec2:CreateSnapshot",
        "ec2:DeleteSnapshot",
        "ec2:DescribeSnapshots",
        "ec2:DescribeInstances",
        "ec2:CreateTags"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_ebs_backup_policy_2" {

  name = "lambda_ebs_backup_policy_2"
  role = "${aws_iam_role.iam_for_lambda_backup_ebs.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "iam_for_lambda_backup_ebs" {
    name = "iam_for_lambda_backup_ebs"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
