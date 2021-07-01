module "vpc" {
  source                = "./modules/vpc"
  gcp_project_id        = "${var.gcp_project_id}"
}

module "subnet" {
  source                = "./modules/subnet"
  region                = "${var.region}"
  vpc_name              = "${module.vpc.vpc_name}"
  subnet_cidr           = "${var.subnet_cidr}"
  subnet_cidr2          = "${var.subnet_cidr2}"
  subnet_cidr3          = "${var.subnet_cidr3}"
  gcp_project_id        = "${var.gcp_project_id}"
}



module "gke" {
  source                = "./modules/gke"
  region                = "${var.region}"
  min_master_version    = "${var.min_master_version}"
  node_version          = "${var.node_version}"
  gke_num_nodes         = "${var.gke_num_nodes}"
  vpc_name              = "${module.vpc.vpc_name}"
  subnet_name           = "${module.subnet.subnet_name}"
  subnet_name2          = "${module.subnet.subnet_name2}"
  subnet_name3          = "${module.subnet.subnet_name3}"
  gke_master_user       = "${var.gke_master_user}"
  gke_master_pass       = "${var.gke_master_pass}"
  gke_node_machine_type = "${var.gke_node_machine_type}"
  gke_label             = "${var.gke_label}"
  gcp_project_id        = "${var.gcp_project_id}"
}

module "cloudsql" {
  source                     = "./modules/cloudsql"
  region                     = "${var.region}"
  availability_type          = "${var.availability_type}"
  sql_instance_size          = "${var.sql_instance_size}"
  sql_disk_type              = "${var.sql_disk_type}"
  sql_disk_size              = "${var.sql_disk_size}"
  sql_require_ssl            = "${var.sql_require_ssl}"
  sql_master_zone            = "${var.sql_master_zone}"
  sql_connect_retry_interval = "${var.sql_connect_retry_interval}"
  sql_replica_zone           = "${var.sql_replica_zone}"
  sql_user                   = "${var.sql_user}"
  sql_pass                   = "${var.sql_pass}"
  gcp_project_id             = "${var.gcp_project_id}"
}

module "redis" {
  source                     = "./modules/redis"
  vpc_name                   = "${module.vpc.vpc_name}"
  availability_tier_type     = "${var.availability_tier_type}"
  gcp_project_id             = "${var.gcp_project_id}"
  region                     = "${var.region}"
}
