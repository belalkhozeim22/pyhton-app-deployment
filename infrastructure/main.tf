# enable apis
resource "google_project_service" "container_api" {
  service = "container.googleapis.com"
}
resource "google_project_service" "compute_api" {
  service = "compute.googleapis.com"
}
resource "google_project_service" "iam_api" {
  service = "iamcredentials.googleapis.com"
}
resource "google_project_service" "artifactregistry_api" {
  service = "artifactregistry.googleapis.com"
}

# create service account for jenkins
resource "google_service_account" "jenkins" {
  account_id   = "jenkins-deployer"
  display_name = "Jenkins Deployer SA"
}

# grant roles to service account 
resource "google_project_iam_member" "jenkins_container_admin" {
  project = var.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.jenkins.email}"
}

resource "google_project_iam_member" "jenkins_storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.jenkins.email}"
}

# resource "google_project_iam_member" "jenkins_artifact_registry_writer" {
#   project = var.project_id
#   role    = "roles/artifactregistry.writer"
#   member  = "serviceAccount:${google_service_account.jenkins.email}"
# }

# kubernetes cluster
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.zone

  remove_default_node_pool = true
  initial_node_count = 1

  network = "default"

  ip_allocation_policy {}

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }
  }
}

# node pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count

  node_config {
    machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}

