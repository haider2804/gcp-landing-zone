# outputs.tf
# Exposes key resource IDs from this module.
# Future modules (networking, IAM) will reference these values.

output "folder_id" {
  description = "The landing-zone folder ID. Used as parent for all LZ projects."
  value = google_folder.landing_zone.name
}

output "network_hub_project_id" {
    description = "Project ID of the Shared VPC Host project."
    value = google_project.network_hub.project_id
  
}

output "network_hub_project_number" {
  description = "Project number of the Shared VPC Host project. Required for Shared VPC attachment."
  value       = google_project.network_hub.number
}

output "dev_project_id" {
  description = "Project ID of the Dev service project."
  value       = google_project.dev.project_id
}

output "prod_project_id" {
  description = "Project ID of the Prod service project."
  value       = google_project.prod.project_id
}

output "audit_project_id" {
  description = "Project ID of the Audit/logging project."
  value       = google_project.audit.project_id
}