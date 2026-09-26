module "vpc" {
  source = "../.."

  name     = "eks-platform-dev-3az"
  vpc_cidr = "10.50.0.0/20"

  availability_zones = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c"
  ]

  tags = {
    Environment = "dev"
    Application = "eks-platform"
    Managed_by  = "Terraform"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}