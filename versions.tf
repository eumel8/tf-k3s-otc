terraform {
  required_providers {
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = ">=1.25.4"
    }
    template = {
      source = "hashicorp/template"
    }
  }
  required_version = ">= 0.14"
}
