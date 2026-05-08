# versions.tf
# Declares the minimum Terraform version and required providers.
# This file is the entry point — Terraform reads it first on every init.

terraform {
  required_version = "> 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "lz-tfstate-998138295919"
    prefix = "live/org-foundationgit status"
  }
}