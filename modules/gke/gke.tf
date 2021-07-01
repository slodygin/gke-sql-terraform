variable "gcp_project_id" {
  description = "The project ID where we'll create the GKE cluster and related resources."
 }

# GKE variables

variable "region" {
  description = "Region of resources"
}

variable "min_master_version" {
  description = "Number of nodes in each GKE cluster zone"
}

variable "node_version" {
  description = "Number of nodes in each GKE cluster zone"
}

variable "gke_num_nodes" {
  type        = map
  description = "Number of nodes in each GKE cluster zone"
}

variable "vpc_name" {
  description = "vpc name"
}
variable "subnet_name" {
  description = "subnet name"
}
variable "subnet_name2" {
  description = "subnet name"
}
variable "subnet_name3" {
  description = "subnet name"
}



variable "gke_master_user" {
  description = "Username to authenticate with the k8s master"
}

variable "gke_master_pass" {
  description = "Username to authenticate with the k8s master"
}

variable "gke_node_machine_type" {
  description = "Machine type of GKE nodes"
}

# k8s variables
variable gke_label {
  type        = map
  description = "label"
}

data "google_client_config" "current" {}

resource "google_container_cluster" "primary" {
  name = "gke-${terraform.workspace}-cluster"
  location = "${var.region}-a"
  project = "${var.gcp_project_id}"

  node_locations = [
    "${var.region}-b",
    "${var.region}-c",
  ]

  //  region              = "${var.region}"
  min_master_version = "${var.min_master_version}"
  node_version       = "${var.node_version}"
  enable_legacy_abac = false
  initial_node_count = "${var.gke_num_nodes[terraform.workspace]}"
  network            = "${var.vpc_name}"
  subnetwork         = "${var.subnet_name}"

  default_max_pods_per_node=50

  ip_allocation_policy {
    cluster_secondary_range_name  = "${var.subnet_name2}"
    services_secondary_range_name = "${var.subnet_name3}"
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }

    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = "${var.gke_label[terraform.workspace]}"
    }

    disk_size_gb = 10
    machine_type = "${var.gke_node_machine_type}"
    tags         = ["gke-node"]
  }
}

provider "kubernetes" {
  host = "https://${google_container_cluster.primary.endpoint}"

  # load_config_file = false

  token = "${data.google_client_config.current.access_token}"
  cluster_ca_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)}"
}

resource "kubernetes_cluster_role_binding" "client_admin" {
  metadata {
    name = "client-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "User"
    name      = "client"
    api_group = "rbac.authorization.k8s.io"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "kube-system"
  }
  subject {
    kind      = "Group"
    name      = "system:masters"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "local_file" "kubeconfig" {
  content = <<EOF
apiVersion: v1
clusters:
- name: gke
  cluster:
    certificate-authority-data: ${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}
    server: https://${google_container_cluster.primary.endpoint}
contexts:
- name: gke
  context:
    cluster: gke
    user: gke
current-context: gke
kind: Config
preferences: {}
users:
- name: gke
  user:
    client-certificate-data: ${google_container_cluster.primary.master_auth.0.client_certificate}
    client-key-data: ${google_container_cluster.primary.master_auth.0.client_key}
EOF
  filename = "kubeconfig.yaml"
}

# The following outputs allow authentication and connectivity to the GKE Cluster.
output "gcp_project_id" {
  value = "${var.gcp_project_id}"
}

output "gcp_network" {
  value = "${var.vpc_name}"
}

output "gcp_subnetwork_name" {
  value = "${var.subnet_name}"
}

output "gke_master_ip" {
  value = "${google_container_cluster.primary.endpoint}"
  sensitive = true
}

output "gke_client_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.client_certificate}"
  sensitive = true
}

output "gke_client_key" {
  value = "${google_container_cluster.primary.master_auth.0.client_key}"
  sensitive = true
}

output "gke_cluster_ca_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
  sensitive = true
}

output "kubeconfig_path" {
  value = "${local_file.kubeconfig.filename}"
}
