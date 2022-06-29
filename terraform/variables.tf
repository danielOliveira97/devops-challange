variable "immutable_ecr_repositories" {
  type        = bool
  description = "value"
  default     = false
}

variable "gh_secret_aws_access_key_id" {
  type        = string
  description = "value"
  default     = ""
}

variable "gh_secret_aws_secret_access_key" {
  type        = string
  description = "value"
  default     = ""
}

variable "github_token" {
  type        = string
  description = "GitHub Token"
  default     = ""
}

variable "app_github_repository" {
  type        = string
  description = "Github Application Repository"
  default     = ""
}

