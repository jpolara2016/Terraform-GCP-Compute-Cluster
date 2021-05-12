### Create VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.environment}-vpc"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "public-subnet" {
  name          = "${var.environment}-public-subnet-${count.index}"
  count         = length(var.public_subnets_cidr)
  ip_cidr_range = element(var.public_subnets_cidr, count.index)
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_compute_subnetwork" "private-subnet" {
  name                     = "${var.environment}-private-subnet-${count.index}"
  count                    = length(var.private_subnets_cidr)
  ip_cidr_range            = element(var.private_subnets_cidr, count.index)
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
}

### Create a public ip for nat service
resource "google_compute_address" "nat-ip" {
  name    = "${var.environment}-nap-ip-${count.index}"
  project = var.project
  region  = var.region
  count   = length(var.private_subnets_cidr)
}

### Create a nat to allow private instances connect to internet
resource "google_compute_router" "nat-router" {
  name    = "${var.environment}-nat-router-${count.index}"
  region  = var.region
  network = google_compute_network.vpc.name
  count   = length(var.private_subnets_cidr)
}

resource "google_compute_router_nat" "nat-gateway" {
  name                               = "${var.environment}-nat-gateway-${count.index}"
  count                              = length(var.private_subnets_cidr)
  router                             = element(google_compute_router.nat-router.*.name, count.index)
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = ["${element(google_compute_address.nat-ip.*.self_link, count.index)}"]
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = element(google_compute_subnetwork.private-subnet.*.self_link, count.index)
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

### Launch Intances in PRIVATE subnet
resource "google_compute_instance" "private-instance" {
  name         = "${var.environment}-private-instance-${count.index}"
  count        = 1
  machine_type = "n1-standard-1"
  zone         = "${element(var.availability_zones, count.index)}"
  tags         = ["${var.environment}", "private-instances"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
  network_interface {
    subnetwork = element(google_compute_subnetwork.private-subnet.*.self_link, count.index)
  }
  metadata_startup_script = "sudo apt update; sudo apt install apache2 -y"
}

### Launch Intances in PUBLIC subnet
resource "google_compute_instance" "public-instance" {
  name         = "${var.environment}-public-instance-${count.index}"
  count        = 1
  machine_type = "n1-standard-1"
  zone         = "${element(var.availability_zones, count.index)}"
  tags         = ["${var.environment}", "public-instances"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
  network_interface {
    subnetwork = element(google_compute_subnetwork.public-subnet.*.self_link, count.index)
    access_config {
        # It will assign external IP to isnatance if not specified
    }
  }
  metadata_startup_script = "sudo apt update; sudo apt install apache2 -y"
}

# Firewall: Allow SSH to all Instances from my Local
resource "google_compute_firewall" "firewall-ssh" {
  name = "${var.environment}-ssh2allinstance-firewall"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
  }
  source_ranges = ["97.102.162.197/32"]
  #target_tags = ["private-instances", "public-instances"]
}

### Firewall: For Instances in Public Subnet
resource "google_compute_firewall" "firewall-public" {
  name = "${var.environment}-public-subnet-firewall"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports = [ "80", "443" ]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["public-instances"]
}

### Firewall: For Instances in Private Subnet
resource "google_compute_firewall" "firewall-private" {
  name = "${var.environment}-private-subnet-firewall"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports = [ "80", "443" ]
  }
  source_ranges = var.public_subnets_cidr # Allow traffic from only Public Subnet
  target_tags = ["private-instances"]
}

### Firewall: SSH through IAP Tunnel
resource "google_compute_firewall" "firewall-iap" {
  name = "${var.environment}-firewall-iap"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
  target_tags = ["private-instances"]
}