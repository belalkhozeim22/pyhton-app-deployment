variable "project_id" {
  type = string
  default = "theta-ember-474415-r8"
}

variable "region" { 
    type = string
    default = "us-central1"
}

variable "zone" { 
    type = string 
    default = "us-central1-a"
}

variable "cluster_name" {
  type    = string
  default = "microservice-gke"
}

variable "machine_type" {
  type    = string
  default = "e2-medium"
}

variable "node_count" {
  type    = number
  default = 2
}
