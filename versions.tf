terraform {
  required_providers {
    opentelekomcloud = {
      source = "terraform-providers/opentelekomcloud"
    }
    template = {
      source = "hashicorp/template"
    }
  }
  required_version = ">= 0.13"
}
