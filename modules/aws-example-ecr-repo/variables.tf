variable "name" {
  description = "ECR repository name."
  type        = string
}

variable "lifecycle_policy" {
  description = "ECR repository lifecycle policy document. Used to override our default policy."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply."
  type        = map(any)
  default     = {}
}
