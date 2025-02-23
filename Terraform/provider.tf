provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
}

# Data Block: Retrieve Caller Identity
data "aws_caller_identity" "current" {}