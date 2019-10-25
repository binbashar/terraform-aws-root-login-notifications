/**
 * Enables notifications to an SNS topic when someone successfully logs in using the root account via the AWS Console.
 *
 * Creates the following resources:
 *
 * * CloudWatch event rule to filter for console logins with the root account.
 * * CloudWatch event target to send notifications to an SNS topic.
 *
 * ## Usage
 *
 * ```hcl
 *
 * module "root-login-notifications" {
 *   source  = "trussworks/root-login-notifications/aws"
 *   version = "1.0.0"
 *
 *   sns_topic_name = "slack-events"
 * }
 * ```
 */

#
# SNS
#

data "aws_sns_topic" "main" {
  name = "${var.sns_topic_name}"
}

#
# CloudWatch Event
#

resource "aws_cloudwatch_event_rule" "main" {
  name          = "iam-root-login"
  description   = "Successful login with root account"
  event_pattern = "${file("${path.module}/event-pattern.json")}"
}

resource "aws_cloudwatch_event_target" "main" {
  rule      = "${aws_cloudwatch_event_rule.main.name}"
  target_id = "send-to-sns"
  arn       = "${data.aws_sns_topic.main.arn}"

  input_transformer = {
    input_template = "\"Successful AWS console login with the root account.\""
  }
}
