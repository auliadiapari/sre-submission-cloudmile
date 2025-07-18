# --- Outputs ---
output "vpc_network_name" {
  description = "Name of the created VPC network"
  value       = google_compute_network.vpc_cloudmile.name
}

output "gke_subnet_name" {
  description = "Name of the created subnetwork"
  value       = google_compute_subnetwork.gke_subnet_cloudmile.name
}

output "vm_subnet_name" {
  description = "Name of the created subnetwork"
  value       = google_compute_subnetwork.vm_subnet_cloudmile.name
}

output "bastion_external_ip" {
  description = "External IP address of the bastion jumphost"
  value       = google_compute_instance.bastion_jumphost.network_interface[0].access_config[0].nat_ip
}

output "bastion_internal_ip" {
  description = "Internal IP address of the bastion jumphost"
  value       = google_compute_address.bastion_internal_ip.address
}

output "gke_cluster_name" {
  description = "Name of the GKE cluster"
  value       = google_container_cluster.gke_cluster_cloudmile.name
}

output "gke_cluster_endpoint" {
  description = "Endpoint of the GKE cluster master"
  value       = google_container_cluster.gke_cluster_cloudmile.endpoint
}

output "gke_service_account_email" {
  description = "Email of the GKE service account"
  value       = google_service_account.gke_cloudmile_sa.email
}

output "bastion_service_account_email" {
  description = "Email of the Bastion service account"
  value       = google_service_account.bastion_cloudmile_sa.email
}