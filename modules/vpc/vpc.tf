variable "gcp_project_id" {
  description = "The project ID where we'll create the GKE cluster and related resources."
}

# Create VPC
resource "google_compute_network" "vpc" {
  name                    = "${terraform.workspace}-vpc"
  auto_create_subnetworks = "false"
  project                 = "${var.gcp_project_id}"
}
# network VPC output

output "vpc_name" {
  value       = "${google_compute_network.vpc.name}"
  description = "The unique name of the network"
}

output "self_link" {
  value       = "${google_compute_network.vpc.self_link}"
  description = "The URL of the created resource"
}
