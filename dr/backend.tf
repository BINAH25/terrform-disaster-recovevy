data "terraform_remote_state" "primary" {
  backend = "s3"
  config = {
    bucket = "dr-project-bucket-pilot"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}


terraform {
  backend "s3" {
    bucket       = "dr-project-bucket-dr"
    key          = "terraform.tfstate"
    region       = "us-west-2"
    encrypt      = true
    use_lockfile = true
  }
}