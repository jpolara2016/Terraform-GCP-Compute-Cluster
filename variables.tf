variable "project" {
  default = "reliable-proton-313220"
}

variable "region" {
  default = "us-east1"
}

variable "availability_zones" {
  default = [ "us-east1-c", "us-east1-d", "us-east1-e" ]
}

variable "environment" {
  default = "test"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets_cidr" {
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

