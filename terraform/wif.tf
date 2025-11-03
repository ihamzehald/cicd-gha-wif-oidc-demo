data "google_project" "project" {
  project_id = var.project_id
}


#resource "google_iam_workload_identity_pool" "gha_pool" {
#  workload_identity_pool_id = "gha-pool"
#  display_name              = "GitHub Actions Pool"
#}

#resource "google_iam_workload_identity_pool_provider" "gha_provider" {
#  workload_identity_pool_id          = google_iam_workload_identity_pool.gha_pool.workload_identity_pool_id
#  workload_identity_pool_provider_id = "gha-wif-provider"
#  display_name                       = "GitHub Actions OIDC Provider"
#  oidc {
#    issuer_uri = "https://token.actions.githubusercontent.com"
#  }
#  attribute_mapping = {
#    "google.subject"       = "assertion.sub"
#    "attribute.repository" = "assertion.repository"
#    "attribute.actor"      = "assertion.actor"
#  }
#}##

# Grant the workload identity pool permission to impersonate the SA
#resource "google_service_account_iam_binding" "wif_binding" {
#  service_account_id = "projects/${data.google_project.project.number}/serviceAccounts/${var.service_account_deployer_email}"
#  role               = "roles/iam.workloadIdentityUser"
#  members = [
#    # grant the whole provider (use attribute mapping to scope to repo if desired)
#    "principalSet://${google_iam_workload_identity_pool_provider.gha_provider.name}"
#  ]
#}