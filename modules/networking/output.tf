output "vpc_id" {
  value = google_compute_network.vpc.id
}

output "private_subnet_id" {
  value = google_compute_subnetwork.private-subnet.*.id
}

output "public_subnet_id" {
  value = google_compute_subnetwork.public-subnet.*.id
}

output "subnets" {
  value = [google_compute_subnetwork.private-subnet.*.id, google_compute_subnetwork.public-subnet.*.id]
}