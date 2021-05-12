provider "google" {

  credentials = file("~/Downloads/gcp_key.json")

  project = var.project
  region  = var.region
}

module "networking" {
  source = "./modules/networking"
  project              = var.project
  region               = var.region
  availability_zones   = var.availability_zones
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
}
