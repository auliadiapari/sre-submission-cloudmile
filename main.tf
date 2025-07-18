# Configure the Google Cloud provider
provider "google" {
  project = var.project_id
  region  = var.region
  credentials = file("/home/hampstead_sim/tf-sa-cloudmile.json")
}

# API
resource "google_project_service" "compute_api" {
  project = var.project_id
  service = "compute.googleapis.com"
  disable_on_destroy = false 
}

resource "google_project_service" "container_api" {
  project = var.project_id
  service = "container.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iam_api" {
  project = var.project_id
  service = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudresourcemanager_api" {
  project = var.project_id
  service = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "logging_api" {
  project = var.project_id
  service = "logging.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "monitoring_api" {
  project = var.project_id
  service = "monitoring.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "serviceusage_api" {
  project = var.project_id
  service = "serviceusage.googleapis.com"
  disable_on_destroy = false
}

# VPC
resource "google_compute_network" "vpc_cloudmile" {
  name                    = "vpc-cloudmile"
  auto_create_subnetworks = false 
  routing_mode            = "REGIONAL"
  depends_on = [google_project_service.compute_api]
}

# GKE Subnet
resource "google_compute_subnetwork" "gke_subnet_cloudmile" {
  name          = "gke-subnet-cloudmile"
  ip_cidr_range = var.gke_subnet_cidr_range
  region        = var.region
  network       = google_compute_network.vpc_cloudmile.id
  depends_on = [google_project_service.compute_api]
}

# VM Subnet 
resource "google_compute_subnetwork" "vm_subnet_cloudmile" {
  name          = "vm-subnet-cloudmile"
  ip_cidr_range = var.vm_subnet_cidr_range
  region        = var.region
  network       = google_compute_network.vpc_cloudmile.id
  depends_on = [google_project_service.compute_api]
}


# SA VM Bastion
resource "google_service_account" "bastion_cloudmile_sa" {
  account_id   = "bastion-cloudmile"
  display_name = "Service Account for Bastion Host Cloudmile"
  project      = var.project_id
  depends_on = [google_project_service.iam_api, google_project_service.cloudresourcemanager_api]
}

# iam editorr
resource "google_project_iam_member" "bastion_editor_iam" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.bastion_cloudmile_sa.email}"
  depends_on = [google_project_service.iam_api, google_project_service.cloudresourcemanager_api]
}

# GKE SA
resource "google_service_account" "gke_cloudmile_sa" {
  account_id   = "gke-cloudmile"
  display_name = "Service Account for GKE Cluster Cloudmile"
  project      = var.project_id
  depends_on = [google_project_service.iam_api, google_project_service.cloudresourcemanager_api]
}

# iam editor
resource "google_project_iam_member" "gke_editor_iam" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.gke_cloudmile_sa.email}"
  depends_on = [google_project_service.iam_api, google_project_service.cloudresourcemanager_api]
}

# static bastion
resource "google_compute_address" "bastion_internal_ip" {
  name         = "bastion-cloudmile-internal-ip"
  subnetwork   = google_compute_subnetwork.vm_subnet_cloudmile.id
  address_type = "INTERNAL"
  region       = var.region
  depends_on = [google_project_service.compute_api]
}

# Bastiion - E2-Small
resource "google_compute_instance" "bastion_jumphost" {
  name         = "bastion-cloudmile"
  machine_type = "e2-small"
  zone         = var.zone
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_cloudmile.id
    subnetwork = google_compute_subnetwork.vm_subnet_cloudmile.id
    network_ip = google_compute_address.bastion_internal_ip.address
    access_config {
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y openssh-server
  EOF

  tags = ["ssh"]
  depends_on = [google_project_service.compute_api]
}

# Firewall
resource "google_compute_firewall" "allow_ssh_bastion" {
  name    = "allow-ssh-bastion"
  network = google_compute_network.vpc_cloudmile.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"] 
  target_tags   = ["ssh"]
  description   = "Allow SSH access to bastion host"
  depends_on = [google_project_service.compute_api]
}

# Router
resource "google_compute_router" "cloud_router" {
  name    = "cloud-router-cloudmile"
  region  = var.region
  network = google_compute_network.vpc_cloudmile.id
  depends_on = [google_project_service.compute_api]
}

# NAT
resource "google_compute_router_nat" "cloud_nat_gateway" {
  name                          = "cloud-nat-cloudmile"
  router                        = google_compute_router.cloud_router.name
  region                        = google_compute_router.cloud_router.region
  nat_ip_allocate_option        = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  depends_on = [google_project_service.compute_api]
}