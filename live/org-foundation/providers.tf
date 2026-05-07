# providers.tf
# Configures how Terraform authenticates and communicates with GCP.
# Credentials come from Application Default Credentials (ADC) set via:
#   gcloud auth application-default login
# No service account keys. No hardcoded credentials. Ever.


provider "google" {
    billing_project = var.bootstrap_project_id
    user_project_override = true
  
}

provider "google-beta" {
    billing_project = var.bootstrap_project_id
    user_project_override = true
  
}