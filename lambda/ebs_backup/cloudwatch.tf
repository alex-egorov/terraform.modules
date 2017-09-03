################################# CLOUD WATCH ##################################

resource "aws_cloudwatch_event_rule" "lambda_backup_ebs_event_rule" {
  name = "lambda_backup_ebs_event_rule"
  description = "Event rule for Lambda EBS Backup"
  schedule_expression = "cron(10 1 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_backup_ebs_event_target" {
  rule = "${aws_cloudwatch_event_rule.lambda_backup_ebs_event_rule.name}"
  target_id = "lambda_backup_ebs"
  arn = "${aws_lambda_function.lambda_backup_ebs.arn}"
}

resource "aws_lambda_permission" "lambda_backup_ebs_permission" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.lambda_backup_ebs.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.lambda_backup_ebs_event_rule.arn}"
}
