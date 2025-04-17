terraform {
  backend "s3" {
    bucket       = "dr-project-bucket-pilot"
    key          = "terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}