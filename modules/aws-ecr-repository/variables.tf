variable "name" {
  type        = "string"
  description = "ECR repository name."
}

variable "lifecycle_policy" {
  type        = "string"
  description = "ECR repository lifecycle policy document. Used to override our default policy."
  default     = ""
}

variable "tags" {
  type        = "map"
  description = "Additional tags to apply."
  default     = {}
}
