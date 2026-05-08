# variables.tf
# Declares all input variables for the org-foundation live configuration.
# Actual values are supplied in terraform.tfvars (which is gitignored).
# This file only declares the shape and description — no real values here.

variable "org_id" {
  description = "GCP Organization ID (numeric). Run: gcloud organizations list"
  type        = string

}

variable "billing_account" {
  description = "GCP Billing Account ID. Run: gcloud billing accounts list"
  type        = string

}


variable "bootstrap_project_id" {
  description = "The manually-created bootstrap project ID that hosts the Terraform state bucket."
  type        = string
  default     = "lz-bootstrap-001"

}

variable "region" {
  description = "Default GCP region for all resources in this landing zone."
  type        = string
  default     = "us-central1"
}

variable "security_contact_email" {
  description = "Email for CIS 1.9 Essential Contacts — receives GCP security and suspension alerts."
  type        = string
}

variable "labels" {
  description = "Default labels applied to all GCP projects. GCP labels are equivalent to Azure tags."
  type        = map(string)
  default = {
    project     = "gcp-landing-zone"
    managed_by  = "terraform"
    owner       = "haider"
    environment = "foundation"
    cost_center = "learning"
  }
}