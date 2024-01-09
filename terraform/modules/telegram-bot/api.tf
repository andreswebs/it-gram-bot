# locals {
#   api_spec_contents = templatefile("${path.module}/tpl/openapi.yaml.tftpl", {
#     region     = local.region
#     lambda_arn = module.alias.lambda_alias_arn
#   })

#   api_spec = yamldecode(local.api_spec_contents)
# }

# resource "aws_api_gateway_rest_api" "this" {
#   depends_on = [module.alias]
#   name       = local.api_spec.info.title
#   body       = local.api_spec_contents
# }

# resource "aws_lambda_permission" "this" {
#   statement_id  = "ApiGatewayInvoke"
#   action        = "lambda:InvokeFunction"
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*"
#   function_name = module.alias.lambda_alias_arn
# }

# resource "aws_api_gateway_deployment" "this" {
#   rest_api_id = aws_api_gateway_rest_api.this.id
#   stage_name  = var.api_stage
# }
