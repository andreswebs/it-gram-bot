module "telegram_bot" {
  source             = "../../modules/telegram-bot"
  service_name       = "imateapot-bot"
  api_stage          = "v1"
  bot_token_param    = var.bot_token_param
  secret_token_param = var.secret_token_param
  openai_token_param = var.openai_token_param
  lambda_image_param = var.lambda_image_param
}
