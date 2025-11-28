terraform {
  backend "s3" {
    bucket = "mlops-tfstate-vsharko"
    key    = "lesson5/terraform.tfstate"
    region = "us-east-1"
    profile = "default" 
  }
}
