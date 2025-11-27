module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "single-instance"

  instance_type = "t3.micro"
  key_name      = "user1"
  monitoring    = true
  subnet_id     = "subnet-0c6f9adce360b5eb3"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
