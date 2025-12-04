terraform {
  backend "s3" {
    bucket = "mlops-tfstate-vsharko"
    key    = "lesson7/terraform.tfstate"
    region = "us-east-1"
    profile = "default" 
  }
}
