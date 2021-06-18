module "cluster" {
  source          = "./terraform/gke"
  gcp_project_id  = "${var.gcp_project_id}"
  gcp_region      = "${var.gcp_region}"
  gcp_zone        = "${var.gcp_zone}"
}

module "db" {
  source          = "./terraform/db"
  gcp_project_id  = "${var.gcp_project_id}"
  gcp_region      = "${var.gcp_region}"
  gcp_zone        = "${var.gcp_zone}"
  gcp_network     = "${module.cluster.gcp_network}"
}
