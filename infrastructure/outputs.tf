# Output kubeconfig info
output "cluster_name" {
  value = google_container_cluster.primary.name
}
output "cluster_endpoint" {
  value = google_container_cluster.primary.endpoint
}
output "kube_ca_certificate" {
  value = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
}
output "jenkins_service_account_email" {
  value = google_service_account.jenkins.email
}
    