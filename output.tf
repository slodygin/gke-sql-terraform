output "db_host_ip" {
  value = "${module.db.host_ip}"
}

output "db_username" {
  value = "${module.db.username}"
}

output "db_password" {
  value = "${module.db.password}"
  sensitive = true
}
output "kubeconfig_path" {
  value = "${module.cluster.kubeconfig_path}"
}

output "gcp_network" {
  value = "${module.cluster.gcp_network}"
}
