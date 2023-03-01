terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}
provider "google" {
  project = "Peterproject"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_compute_network" "vpc_network" {
  name = "fyp-network"
  auto_create_subnetworks = false
  mtu                     = 1460
}


resource "google_compute_subnetwork"  "default" {
  name = "fyp-subnetwork"
  ip_cidr_range = "10.0.1.0/24"
  region = "us-central1"
  network = google_compute_network.vpc_network.id
}

resource "google_compute_instance" "default" {
    name = "fyp1-vm"
    machine_type = "e2-medium"
    zone = "us-central1-c"
    tags = ["ssh"]

    boot_disk {
      initialize_params {
        image = "debian-cloud/debian-11"
      }
    }
    
    metadata_startup_script = "sudo apt-get update ; sudo apt-get install -yq build-essential git python3-pip rsync ; sudo pip install flask ; sudo git clone https://github.com/protoncb/login-page.git /home/login-page ; sudo chown -R user:user /home/user/login-page"

    network_interface {
        subnetwork = google_compute_subnetwork.default.id

        access_config{

        }
    }
} 

resource "google_compute_firewall" "ssh" {
  name = "allow-ssh"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}