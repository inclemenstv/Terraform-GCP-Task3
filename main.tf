terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.70.0"
    }
  }
}

// Configure the Google Cloud provider
provider "google" {
 credentials = "${file("${var.credentials}")}"
 project     = "${var.gcp_project}"
 region      = "${var.region}"
}
// Create VPC
resource "google_compute_network" "vpc" {
 name                    = "${var.network_name}-vpc"
 auto_create_subnetworks = "false"
}

// Create Subnet
resource "google_compute_subnetwork" "subnet" {
 name          = "${var.network_name}-subnet"
 ip_cidr_range = "${var.subnet_cidr}"
 network       = "${var.network_name}-vpc"
 depends_on    = ["google_compute_network.vpc"]
 region        = "${var.region}"
}
// VPC firewall configuration
resource "google_compute_firewall" "firewall" {
  name    = "${var.network_name}-firewall"
  network = "${google_compute_network.vpc.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

// Create instance
resource "google_compute_instance" "vm_instance" {
  count        = var.instance_count
  name         = "${var.instance_name}-instance-${count.index}"
  zone         = "${var.zone}"
  machine_type = "${var.machine_type}"

  boot_disk {
    initialize_params {
      image = "${var.instance_image}"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.name
    access_config {
    }
  }
}

output "virtual_machines" {
  value = [
    for i, vm in google_compute_instance.vm_instance : {
      name = vm.name
      id   = vm.id

      private_ip   = google_compute_instance.vm_instance[i].network_interface.0.network_ip
      public_ip    = google_compute_instance.vm_instance[i].network_interface.0.access_config.0.nat_ip
    }
  ]
}