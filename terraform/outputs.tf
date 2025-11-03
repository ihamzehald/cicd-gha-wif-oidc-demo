output "service_url" {
  value = google_cloud_run_service.cicd-gha-wif-cr-app.status[0].url
}