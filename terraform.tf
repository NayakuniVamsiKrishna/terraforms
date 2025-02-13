terraform {
  backend "s3" {
    bucket   = "campaigns-terraform-state"
    region   = "us-west-2"
    key      = "terraform.tfstate"
  }
}
