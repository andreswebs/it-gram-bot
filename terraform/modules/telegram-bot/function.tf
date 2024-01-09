locals {
  ssm_param_arn_prefix   = "arn:${local.aws_partition}:ssm:${local.region}:${local.account_id}:parameter"
  bot_token_param_arn    = "${local.ssm_param_arn_prefix}${var.bot_token_param}"
  secret_token_param_arn = "${local.ssm_param_arn_prefix}${var.secret_token_param}"
  openai_token_param_arn = "${local.ssm_param_arn_prefix}${var.openai_token_param}"
}

locals {
  lambda_env = {
    SSM_PARAM_TELEGRAM_BOT_TOKEN    = var.bot_token_param
    SSM_PARAM_TELEGRAM_SECRET_TOKEN = var.secret_token_param
    SSM_PARAM_OPENAI_TOKEN          = var.openai_token_param
  }

  lambda_alias = "live"

}

data "aws_ssm_parameter" "lambda_image" {
  name            = var.lambda_image_param
  with_decryption = true
}

module "lambda_base" {
  source  = "andreswebs/lambda-container/aws"
  version = "4.0.0"

  create_lambda = false
  use_id        = false

  lambda_image_uri = ""

  lambda_name_prefix = var.service_name

}

data "aws_iam_policy_document" "lambda_ssm_permissions" {

  statement {
    sid       = "SSMDescribe"
    actions   = ["ssm:DescribeParameters"]
    resources = ["*"]
  }

  statement {
    sid = "SSMGet"

    actions = [
      "ssm:GetParametersByPath",
      "ssm:GetParameters",
      "ssm:GetParameter",
      "ssm:GetParameterHistory",
    ]

    resources = [
      local.bot_token_param_arn,
      local.secret_token_param_arn,
      local.openai_token_param_arn,
    ]
  }

}

resource "aws_iam_role_policy" "lambda_ssm_permissions" {
  name   = "ssm-permissions"
  role   = module.lambda_base.role.id
  policy = data.aws_iam_policy_document.lambda_ssm_permissions.json
}

module "lambda" {
  depends_on                 = [module.lambda_base]
  source                     = "terraform-aws-modules/lambda/aws"
  function_name              = var.service_name
  description                = var.service_description
  image_uri                  = data.aws_ssm_parameter.lambda_image.value
  create_lambda_function_url = false
  create_role                = false
  create_package             = false
  environment_variables      = local.lambda_env
  lambda_role                = module.lambda_base.role.arn
  package_type               = "Image"
  publish                    = true
  memory_size                = 2048
  timeout                    = 600

  use_existing_cloudwatch_log_group = true
}

module "alias" {
  depends_on       = [module.lambda]
  source           = "terraform-aws-modules/lambda/aws//modules/alias"
  refresh_alias    = true
  name             = "live"
  function_name    = module.lambda.lambda_function_name
  function_version = module.lambda.lambda_function_version
}

module "deploy" {
  source         = "terraform-aws-modules/lambda/aws//modules/deploy"
  depends_on     = [module.alias]
  alias_name     = module.alias.lambda_alias_name
  function_name  = module.lambda.lambda_function_name
  target_version = module.lambda.lambda_function_version

  create_app = true
  app_name   = var.service_name

  create_deployment_group    = true
  deployment_group_name      = "default"
  create_deployment          = true
  run_deployment             = true
  save_deploy_script         = false
  wait_deployment_completion = true

  force_deploy = true
}


resource "aws_lambda_function_url" "this" {
  depends_on         = [module.alias]
  function_name      = module.lambda.lambda_function_name
  qualifier          = module.alias.lambda_alias_name
  authorization_type = "NONE"
}
