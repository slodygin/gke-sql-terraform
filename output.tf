output "kubeconfig_path" {
  value = "${module.gke.kubeconfig_path}"
}

output "gcp_network" {
  value = "${module.gke.gcp_network}"
}

output "db_host_ip" {
  value = "${module.cloudsql.host_ip}"
}

output "db_username" {
  value = "${module.cloudsql.username}"
}

output "db_password" {
  value = "${module.cloudsql.password}"
  sensitive = true
}

output "redis_host_ip" {
  value = "${module.redis.host_ip_redis}"
}

output "redis_host_port" {
  value = "${module.redis.host_port_redis}"
}
