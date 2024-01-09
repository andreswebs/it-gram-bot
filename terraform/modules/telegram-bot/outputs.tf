output "invoke_url" {
  value       = aws_lambda_function_url.this.function_url
  description = "The generated invoke URL"
}
