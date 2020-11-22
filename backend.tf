terraform {
  backend "s3" {
    # hint: access_key, secret_key and key is set via terraform init
    bucket                      = "tf-k3s-state"
    endpoint                    = "obs.eu-de.otc.t-systems.com"
    skip_region_validation      = true
    skip_credentials_validation = true
    region                      = "eu-de"
  }
}

