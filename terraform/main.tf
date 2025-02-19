terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "cloud-talents"

    workspaces {
      name = "tech-blog"
    }
  }
}