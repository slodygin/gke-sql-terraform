variable "gcp_project_id" {
  description = "The project ID where we'll create the GKE cluster and related resources."
}

variable "vpc_name" {
  description = "vpc name"
}

variable "availability_tier_type" {
  type        = map
  description = "Availability tier type for HA"
}

variable "region" {
  description = "Region of resources"
}

resource "google_redis_instance" "redis" {
  name                    = "private-redis-${terraform.workspace}"
  tier                    = "${var.availability_tier_type[terraform.workspace]}"
  memory_size_gb          = 1

  location_id             = "us-central1-a"
  alternative_location_id = "us-central1-f"

  redis_version           = "REDIS_5_0"
  display_name            = "Terraform Test Instance"
  project                 = "${var.gcp_project_id}"
  region                  = "${var.region}"

}

output "host_ip_redis" {
  value = "${google_redis_instance.redis.host}"
}
output "host_port_redis" {
  value = "${google_redis_instance.redis.port}"
}
