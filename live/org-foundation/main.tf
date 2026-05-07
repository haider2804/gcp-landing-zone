# main.tf
# Org Foundation — creates the folder, projects, org policies,
# essential contacts, and billing budget for the landing zone.

# ─────────────────────────────────────────────────────────────
# 1. FOLDER
# Creates a folder called "landing-zone" directly under the Org.
# All four projects live inside this folder.
# Think of it as a "subscription group" equivalent in Azure.
# ─────────────────────────────────────────────────────────────

resource "google_folder" "landing_zone" {
    display_name = "landing-zone"
    parent = "organizations/${var.org_id}"
  
}

# ─────────────────────────────────────────────────────────────
# 2. PROJECTS
# Each project is an isolated billing + IAM + API boundary.
# Project IDs must be globally unique across ALL of GCP.
# We suffix with the org ID to ensure uniqueness.
# ─────────────────────────────────────────────────────────────

# Shared VPC Host Project — owns the network infrastructure.
# No application workloads run here.

resource "google_project" "network_hub" {
    name = "LZ Network Hub"
    project_id = "lz-net-hub-${var.org_id}"
    folder_id = google_folder.landing_zone.name
    billing_account = var.billing_account
    labels = merge(var.labels, {environment = "shared", purpose = "network-host"})

    lifecycle {
      prevent_destroy = false
    }
  
}

resource "google_project" "dev" {
  name            = "LZ Dev"
  project_id      = "lz-dev-${var.org_id}"
  folder_id       = google_folder.landing_zone.name
  billing_account = var.billing_account
  labels          = merge(var.labels, { environment = "dev" })
}

resource "google_project" "prod" {
  name            = "LZ Prod"
  project_id      = "lz-prod-${var.org_id}"
  folder_id       = google_folder.landing_zone.name
  billing_account = var.billing_account
  labels          = merge(var.labels, { environment = "prod" })

  lifecycle {
    prevent_destroy = false
  }
}


# Audit Project — receives centralized log sink from all projects
resource "google_project" "audit" {
  name            = "LZ Audit"
  project_id      = "lz-audit-${var.org_id}"
  folder_id       = google_folder.landing_zone.name
  billing_account = var.billing_account
  labels          = merge(var.labels, { environment = "shared", purpose = "audit-logs" })

  lifecycle {
    prevent_destroy = false
  }
}


# ─────────────────────────────────────────────────────────────
# 3. ORG POLICY — CIS 3.1
# Prevents any new project from getting a default VPC network. The default network has overly permissive firewall rules.
# It allows SSH and RDP from the entire internet (0.0.0.0/0). Enforcing this at Org level means every future project is safe
# from the moment it is created.
# ─────────────────────────────────────────────────────────────

resource "google_org_policy_policy" "skip_default_network" {
  name   = "organizations/${var.org_id}/policies/compute.skipDefaultNetworkCreation"
  parent = "organizations/${var.org_id}"

  spec {
    rules {
      enforce = "TRUE"
    }
  }
}

# ─────────────────────────────────────────────────────────────
# 4. ORG POLICY — CIS 1.6
# Disables creation of user-managed service account keys.
# Downloadable SA keys are a major attack surface — they don't
# expire, they can be emailed/leaked, and they bypass IP
# restrictions. Disabling this forces use of Workload Identity
# or short-lived tokens instead.
# ─────────────────────────────────────────────────────────────
resource "google_org_policy_policy" "disable_sa_key_creation" {
  name   = "organizations/${var.org_id}/policies/iam.disableServiceAccountKeyCreation"
  parent = "organizations/${var.org_id}"

  spec {
    rules {
      enforce = "TRUE"
    }
  }
}


resource "google_essential_contacts_contact" "security_org" {
    provider = google-beta
    parent = "organizations/${var.org_id}"
    email = var.security_contact_email
    language_tag = "en-US"
    notification_category_subscriptions = ["SECURITY", "SUSPENSION", "TECHNICAL"]
  
}


# ─────────────────────────────────────────────────────────────
# 6. BILLING BUDGET — Credit Protection
# Sends email alerts at 50/80/90/100% of $250 spend.
# Budget is set to $250 (not $300) to give a safety buffer
# before the full $300 free trial is exhausted.
# This does NOT stop resources — alerts only.
# To stop resources you would need Budget → Pub/Sub → Cloud Function.
# ─────────────────────────────────────────────────────────────

resource "google_billing_budget" "landing_zone_budget" {
    billing_account = var.billing_account
    display_name = "LZ-Total-Budget-Guard"

    budget_filter {
      projects = [
        "projects/${google_project.network_hub.number}",
      "projects/${google_project.dev.number}",
      "projects/${google_project.prod.number}",
      "projects/${google_project.audit.number}",
      ]
    }

    amount {
    specified_amount {
      currency_code = "USD"
      units         = "250"
    }
  }

  threshold_rules {
    threshold_percent = 0.5
    spend_basis       = "CURRENT_SPEND"
  }
  threshold_rules {
    threshold_percent = 0.8
    spend_basis       = "CURRENT_SPEND"
  }
  threshold_rules {
    threshold_percent = 0.9
    spend_basis       = "CURRENT_SPEND"
  }
  threshold_rules {
    threshold_percent = 1.0
    spend_basis       = "CURRENT_SPEND"
  }
}