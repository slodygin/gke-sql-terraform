variable "gcp_project_id" {
  description = "The project ID where we'll create the GKE cluster and related resources."
}

# Subnet variables
variable "region" {
  description = "Region of resources"
}

variable "vpc_name" {
  description = "Netwrok name"
}

variable "subnet_cidr" {
  type        = map
  description = "Subnet range"
}

# Create Subnet

resource "google_compute_subnetwork" "subnet" {
  name          = "${terraform.workspace}-subnet"
  ip_cidr_range = "${var.subnet_cidr[terraform.workspace]}"
  network       = "${var.vpc_name}"
  region        = "${var.region}"
  project                 = "${var.gcp_project_id}"
}


# network subnet output

output "ip_cidr_range" {
  value       = "${google_compute_subnetwork.subnet.ip_cidr_range}"
  description = "Export created CICDR range"
}

output "subnet_name" {
  value       = "${google_compute_subnetwork.subnet.name}"
  description = "Export created CICDR range"
}
