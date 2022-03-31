# This SSM parameter contains our Slack webhook URL that we've added
# manually so that it can be safely pulled here; it's a secret, so we
# don't want to leave it in code anywhere.

data "aws_ssm_parameter" "slack_webhook_url" {
  name = "/slack/webhook/url/orgname-infra"
}

#
# IAM
#

# These policies allow AWS resources to write to the SNS topic we use
# for Slack notifications, and we attach these to the respective SNS
# topics. We need one in each region because services in a region can
# really only add messages to topics in their region.

data "aws_iam_policy_document" "notify_slack_topic_policy_useast1" {

  statement {
    sid = "__default_statement_ID"

    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [data.aws_caller_identity.current.account_id]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.notify_slack_useast1.arn
    ]
  }

  statement {
    sid    = "allow-cloudwatch"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions   = ["SNS:Publish"]
    resources = [aws_sns_topic.notify_slack_useast1.arn]
  }
}

data "aws_iam_policy_document" "notify_slack_topic_policy_uswest2" {

  statement {
    sid = "__default_statement_ID"

    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [data.aws_caller_identity.current.account_id]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.notify_slack_uswest2.arn
    ]
  }

  statement {
    sid    = "allow-cloudwatch"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions   = ["SNS:Publish"]
    resources = [aws_sns_topic.notify_slack_uswest2.arn]
  }
}

#
# SNS
#

# These two SNS topics are the bridge between AWS services and our Slack
# server. Note that we're attaching the policies we defined above.

resource "aws_sns_topic_policy" "notify_slack_useast1" {
  provider = aws.us-east-1

  arn = aws_sns_topic.notify_slack_useast1.arn

  policy = data.aws_iam_policy_document.notify_slack_topic_policy_useast1.json
}

resource "aws_sns_topic_policy" "notify_slack_uswest2" {
  arn = aws_sns_topic.notify_slack_uswest2.arn

  policy = data.aws_iam_policy_document.notify_slack_topic_policy_uswest2.json
}

# 2019-01-16 (dynamike) - There's a bug in the notify-slack Terraform module that
# requires creating the SNS topic before you can create the notify-slack module.
# https://github.com/terraform-aws-modules/terraform-aws-notify-slack/issues/46
resource "aws_sns_topic" "notify_slack_useast1" {
  provider = aws.us-east-1

  name = "notify-slack"
}

resource "aws_sns_topic" "notify_slack_uswest2" {
  name = "notify-slack"
}

#
# Lambda
#

# These Lambdas consume messages from the SNS topics defined above, build
# properly-formatted Slack messages, and then send them to webhook URL we
# added to SSM.

module "notify_slack_useast1" {
  providers = {
    aws = aws.us-east-1
  }

  source  = "terraform-aws-modules/notify-slack/aws"
  version = "~> 5.0.0"

  lambda_function_name = "notify_slack_useast1"
  create_sns_topic     = false
  sns_topic_name       = aws_sns_topic.notify_slack_useast1.name

  slack_webhook_url = data.aws_ssm_parameter.slack_webhook_url.value
  slack_channel     = "orgname-infra"
  slack_username    = "aws-org-alerts"
}

module "notify_slack_uswest2" {
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "~> 5.0.0"

  lambda_function_name = "notify_slack_uswest2"
  create_sns_topic     = false
  sns_topic_name       = aws_sns_topic.notify_slack_uswest2.name

  slack_webhook_url = data.aws_ssm_parameter.slack_webhook_url.value
  slack_channel     = "orgname-infra"
  slack_username    = "aws-org-alerts"
}
