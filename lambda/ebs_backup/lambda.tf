################################### LAMBDA #####################################


data "archive_file" "lambda_backup_ebs_code" {
  type = "zip"
  source_file = "${path.module}/scripts/ebs_backup.py"
  output_path = "${path.module}/scripts/ebs_backup.zip"
}


resource "aws_lambda_function" "lambda_backup_ebs" {
  runtime = "python2.7"
  timeout = 10

  role = "${aws_iam_role.iam_for_lambda_backup_ebs.arn}"
  filename = "${data.archive_file.lambda_backup_ebs_code.output_path}"
  function_name = "ebs_backup_function"
  handler = "ebs_backup.lambda_handler"

  source_code_hash = "${data.archive_file.lambda_backup_ebs_code.output_base64sha256}"

  environment {
    variables = {
      servers = "${var.ebs_backup_pattern}"
    }
  }
}
