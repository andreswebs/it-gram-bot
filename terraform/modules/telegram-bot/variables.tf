variable "service_name" {
  type        = string
  description = "Service name, also used to compose various AWS resource names"
  default     = "it-gram-bot"
}

variable "service_description" {
  type        = string
  description = "Service description"
  default     = "Private Telegram Bot"
}

variable "bot_token_param" {
  type        = string
  description = "Name of the SSM parameter storing the Bot API token"
  default     = "/telegram-bot/token"
}

variable "openai_token_param" {
  type        = string
  description = "Name of the SSM parameter storing the OpenAI API token"
  default     = "/openai/token"
}

variable "secret_token_param" {
  type        = string
  description = "Name of the SSM parameter storing the Bot secret token"
  default     = "/telegram-bot/secret"
}

variable "api_stage" {
  type        = string
  description = "API Gateway deployment stage"
  default     = "v1"
}

variable "lambda_image_param" {
  type        = string
  description = "Name of the SSM parameter storing the Lambda container image to deploy"
}
