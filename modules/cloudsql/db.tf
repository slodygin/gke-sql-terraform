variable "region" {
  description = "The region where we'll create your resources (e.g. us-central1)."
}
variable "gcp_project_id" {
  description = "The project ID where we'll create the GKE cluster and related resources."
}
# Cloud SQL variables

variable "availability_type" {
  type        = map
  description = "Availability type for HA"
}

variable "sql_instance_size" {
  description = "Size of Cloud SQL instances"
}

variable "sql_disk_type" {
  description = "Cloud SQL instance disk type"
}

variable "sql_disk_size" {
  description = "Storage size in GB"
}

variable "sql_require_ssl" {
  description = "Enforce SSL connections"
}

variable "sql_connect_retry_interval" {
  description = "The number of seconds between connect retries."
}

variable "sql_master_zone" {
  description = "Zone of the Cloud SQL master (a, b, ...)"
}

variable "sql_replica_zone" {
  description = "Zone of the Cloud SQL replica (a, b, ...)"
}

variable "sql_user" {
  description = "Username of the host to access the database"
}

variable "sql_pass" {
  description = "Password of the host to access the database"
}

#provider "random" {}

resource "random_id" "id" {
  byte_length = 4
  prefix      = "sql-${terraform.workspace}-"
}

resource "google_sql_database_instance" "master" {
  name             = "private-instance-${random_id.id.hex}"
  database_version = "POSTGRES_11"
  region           = "${var.region}"
  project          = "${var.gcp_project_id}"

  settings {
    availability_type = "${var.availability_type[terraform.workspace]}"
    tier              = "${var.sql_instance_size}"
    disk_type         = "${var.sql_disk_type}"
    disk_size         = "${var.sql_disk_size}"
    disk_autoresize   = true

    ip_configuration {
      authorized_networks {
        value = "0.0.0.0/0"
      }

      require_ssl  = "${var.sql_require_ssl}"
      ipv4_enabled = true
    }

    location_preference {
      zone = "${var.region}-${var.sql_master_zone}"
    }

    backup_configuration {
#      binary_log_enabled = true
      enabled            = true
      start_time         = "00:00"
    }
  }
}

resource "google_sql_database_instance" "replica" {
  depends_on = [
    google_sql_database_instance.master,
  ]

  name                 = "private-instance-${terraform.workspace}-replica"
  count                = "${terraform.workspace == "prod" ? 1 : 0}"
  region               = "${var.region}"
  project              = "${var.gcp_project_id}"
  database_version     = "POSTGRES_11"
  master_instance_name = "${google_sql_database_instance.master.name}"

  settings {
    tier            = "${var.sql_instance_size}"
    disk_type       = "${var.sql_disk_type}"
    disk_size       = "${var.sql_disk_size}"
    disk_autoresize = true

    location_preference {
      zone = "${var.region}-${var.sql_replica_zone}"
    }
  }
}

resource "google_sql_user" "user" {
  depends_on = [
    google_sql_database_instance.master,
    google_sql_database_instance.replica,
  ]

  instance = "${google_sql_database_instance.master.name}"
  name     = "${var.sql_user}"
  password = "${var.sql_pass}"
  project  = "${var.gcp_project_id}"
  provisioner "local-exec" {
    command = "psql postgresql://${google_sql_user.user.name}:${google_sql_user.user.password}@${google_sql_database_instance.master.ip_address.0.ip_address}/postgres -c \"CREATE DATABASE test;\""
  }

}

output "host_ip" {
  value = "${google_sql_database_instance.master.ip_address.0.ip_address}"
}

output "username" {
  value = "${google_sql_user.user.name}"
}

output "password" {
  value = "${google_sql_user.user.password}"
}
