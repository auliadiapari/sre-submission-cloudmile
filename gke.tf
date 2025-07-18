# GKE Cluster
resource "google_container_cluster" "gke_cluster_cloudmile" {
  name               = "cluster-cloudmile"
  location           = var.zone
  project            = var.project_id
  deletion_protection = false
  initial_node_count = 1
  network    = google_compute_network.vpc_cloudmile.id
  subnetwork = google_compute_subnetwork.gke_subnet_cloudmile.id

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false 
    master_ipv4_cidr_block  = "172.16.0.0/28" 
  }
  ip_allocation_policy {
    cluster_secondary_range_name  = google_compute_subnetwork.gke_subnet_cloudmile.secondary_ip_range[0].range_name
    services_secondary_range_name = google_compute_subnetwork.gke_subnet_cloudmile.secondary_ip_range[1].range_name
  }

  remove_default_node_pool = true

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  release_channel {
    channel = "REGULAR"
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "${google_compute_address.bastion_internal_ip.address}/32"
      display_name = google_compute_address.bastion_internal_ip.name
    }
    
    cidr_blocks {
      cidr_block = "0.0.0.0/0"
      display_name = "public"
    }
  }
  depends_on = [
    google_project_service.container_api,
    google_project_service.compute_api,
    google_project_service.logging_api,
    google_project_service.monitoring_api,
    google_project_service.iam_api,
    google_project_service.serviceusage_api
  ]
}

# GKE Nodepool
resource "google_container_node_pool" "pool_cloudmile" {
  name       = "pool-cloudmile"
  location   = var.zone
  cluster    = google_container_cluster.gke_cluster_cloudmile.name
  node_count = 1

  node_config {
    machine_type = "n1-standard-1"
    disk_size_gb = var.gke_node_disk_size_gb
    service_account = google_service_account.gke_cloudmile_sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
  management {
    auto_repair  = true
    auto_upgrade = true
  }
  depends_on = [google_project_service.container_api]
}


