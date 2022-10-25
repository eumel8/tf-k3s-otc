terraform {
  backend "s3" {
    # hint: access_key, secret_key, key,bucket,endpoint,region is set via terraform init
    bucket                      = "" # "tf-k3s-state"
    endpoint                    = "" # "obs.eu-de.otc.t-systems.com"
    region                      = "" # "eu-de"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

