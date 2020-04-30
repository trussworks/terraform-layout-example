output "arn" {
  description = "Full ARN of the repository."
  value       = aws_ecr_repository.main.arn
}
