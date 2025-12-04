variable "aws_profile" {
  description = "AWS CLI profile"
  type        = string
  default     = "default"
}

variable "aws_region" {
  description = "AWS region for AWS provider"
  type        = string
  default     = "us-east-1"
}

variable "eks_state_bucket" {
  description = "S3 bucket з remote state EKS"
  type        = string
  default     = "mlops-tfstate-vsharko"
}

variable "eks_state_key" {
  description = "S3 key для remote state EKS"
  type        = string
  default     = "lesson5/terraform.tfstate"
}

variable "eks_state_region" {
  description = "Регіон бакета з remote state EKS"
  type        = string
  default     = "us-east-1"
}

variable "argocd_namespace" {
  description = "Namespace для Argo CD"
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "Версія Helm-чарту Argo CD"
  type        = string
  default     = "v7.7.5"
}

variable "app_repo_url" {
  description = "Git repo URL"
  type        = string
  default     = "https://github.com/vasiliy-sharko/mlops-course-argocd.git"
}

variable "app_repo_branch" {
  description = "Branch to use"
  type        = string
  default     = "main"
}

