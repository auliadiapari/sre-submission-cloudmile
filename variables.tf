# --- Variables ---
variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = "coastal-wares-466112-d4"
}

variable "region" {
  description = "The GCP region for the VPC and subnet"
  type        = string
  default     = "asia-southeast2"
}

variable "zone" {
  description = "The GCP zone for the GKE cluster and bastion host"
  type        = string
  default     = "asia-southeast2-a"
}

variable "bucket_name" {
  description = "GCP Cloud storage bucket name"
  type        = string
  default     = "nexus-blob-storage-cloudmile"
}

variable "vm_subnet_cidr_range" {
  description = "The primary CIDR range for the VM custom subnet"
  type        = string
  default     = "10.0.0.0/28"
}

variable "gke_subnet_cidr_range" {
  description = "The primary CIDR range for the GKE custom subnet"
  type        = string
  default     = "10.0.20.0/22"
}

variable "gke_pods_secondary_range_cidr" {
  description = "The secondary CIDR range for GKE Pods"
  type        = string
  default     = "10.10.0.0/16"
}

variable "gke_services_secondary_range_cidr" {
  description = "The secondary CIDR range for GKE Services"
  type        = string
  default     = "10.20.0.0/20"
}

variable "gke_node_disk_size_gb" {
  description = "Disk size in GB for GKE cluster nodes"
  type        = number
  default     = 50
}