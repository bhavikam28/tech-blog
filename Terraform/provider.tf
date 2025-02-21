
# AWS Provider Configuration
provider "aws" {
  region = var.primary_region

    # Use OIDC for authentication
  assume_role {
    role_arn = var.aws_role_arn
  }
}

# AWS Provider Configuration
provider "aws" {
  alias  = "secondary"  
  region = var.secondary_region

    # Use OIDC for authentication
  assume_role {
    role_arn = var.aws_role_arn
  }
}


# Data Block: Retrieve Caller Identity
data "aws_caller_identity" "current" {}