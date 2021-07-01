variable "gcp_project_id" {
  description = "The project ID."
}

variable "region" {
  description = "The region where we'll create your resources (e.g. us-central1)."
}

variable "gcp_zone" {
  description = "The zone where we'll create your resources (e.g. us-central1-b)."
}

variable "name" {
  default = {
    prod = "prod"
    dev  = "dev"
  }

  description = "Name for vpc"
}

# Network variables

variable "subnet_cidr" {
  default = {
    prod = "10.10.0.0/24"
    dev  = "10.240.0.0/24"
  }
  description = "Subnet range"
}
variable "subnet_cidr2" {
  default = {
    prod = "192.168.100.0/22"
    dev  = "192.168.108.0/22"
  }
  description = "Subnet range"
}
variable "subnet_cidr3" {
  default = {
    prod = "192.168.104.0/22"
    dev  = "192.168.112.0/22"
  }
  description = "Subnet range"
}

# Cloud SQL variables

variable "availability_type" {
  default = {
    prod = "REGIONAL"
    dev  = "ZONAL"
  }

  description = "Availability type for HA"
}

variable "sql_instance_size" {
  default     = "db-f1-micro"
  description = "Size of Cloud SQL instances"
}

variable "sql_disk_type" {
  default     = "PD_SSD"
  description = "Cloud SQL instance disk type"
}

variable "sql_disk_size" {
  default     = "10"
  description = "Storage size in GB"
}

variable "sql_require_ssl" {
  default     = "false"
  description = "Enforce SSL connections"
}

variable "sql_master_zone" {
  default     = "a"
  description = "Zone of the Cloud SQL master (a, b, ...)"
}

variable "sql_replica_zone" {
  default     = "b"
  description = "Zone of the Cloud SQL replica (a, b, ...)"
}

variable "sql_connect_retry_interval" {
  default     = 60
  description = "The number of seconds between connect retries."
}

variable "sql_user" {
  default     = "admin"
  description = "Username of the host to access the database"
}

variable "sql_pass" {
  description = "Password of the host to access the database"
}

# GKE variables

variable "min_master_version" {
  default     = "1.19.10-gke.1600"
  description = "Min GKE master version"
}

variable "node_version" {
  default     = "1.19.10-gke.1600"
  description = "GKE node version"
}

variable "gke_num_nodes" {
  default = {
    prod = 2
    dev  = 1
  }
  description = "Number of nodes in each GKE cluster zone"
}

variable "gke_master_user" {
  default     = "k8s_admin"
  description = "Username to authenticate with the k8s master"
}

variable "gke_master_pass" {
  description = "Username to authenticate with the k8s master"
}

variable "gke_node_machine_type" {
  default     = "n1-standard-1"
  description = "Machine type of GKE nodes"
}

variable gke_label {
  default = {
    prod = "prod"
    dev  = "dev"
  }

  description = "label"
}

#redis variables
variable "availability_tier_type" {
  default = {
    prod = "STANDARD_HA"
    dev  = "BASIC"
  }
}
