# Locals
 
locals {
  default_firewall_rules = [
    {
      name        = "dnb-default-allow-private-endpoint-egress-${var.vpc_suffix}"
      direction   = "EGRESS"
      priority    = 65532
      description = "Allow egress traffic to private endpoints and log"
      ranges      = ["199.36.153.4/30", "199.36.153.8/30"]
      allow = [{
        protocol = "all"
        ports    = []
      }]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    {
      name        = "dnb-default-deny-all-ingress-${var.vpc_suffix}"
      direction   = "INGRESS"
      priority    = 65533
      description = "Deny all ingress traffic and log"
      ranges      = ["0.0.0.0/0"]
      allow       = []
      deny = [{
        protocol = "all"
        ports    = []
      }]
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    {
      name        = "dnb-default-deny-all-egress-${var.vpc_suffix}"
      direction   = "EGRESS"
      priority    = 65533
      description = "Deny all egress traffic and log"
      ranges      = ["0.0.0.0/0"]
      allow       = []
      deny = [{
        protocol = "all"
        ports    = []
      }]
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
  ]
 
  default_vpc_routes = [
    {
      description       = "route for private google access enablement",
      destination_range = "199.36.153.8/30",
      name              = "private-google-access-route-${var.vpc_suffix}",
      next_hop_internet = "true"
    },
    {
      description       = "route for KMS windows activation",
      destination_range = "35.190.247.13/32",
      name              = "ms-kms-route-${var.vpc_suffix}",
      next_hop_internet = "true"
    }
  ]
 
  vpc_name = "${var.environment}-${var.vpc_suffix}"
 
  # i is the index, v is the subnet value
  subnets = [
    for i, v in var.vpc_subnets :
    {
      subnet_name           = v.subnet_name
      subnet_region         = v.subnet_region
      subnet_ip             = v.subnet_ip
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = v.description
    }
  ]
}
 
module "shared-vpc" {
  source  = "terraform-google-modules/network/google"
  version = "5.0.0"
 
  delete_default_internet_gateway_routes = true
  project_id                             = var.project_id
  network_name                           = local.vpc_name
  routing_mode                           = "GLOBAL"
  shared_vpc_host                        = var.shared_vpc_host_enable
 
  subnets = local.subnets
 
  firewall_rules = concat(local.default_firewall_rules, var.firewall_rules)
  routes         = concat(local.default_vpc_routes, var.vpc_routes)
 
}
 
# PSA Configuration
 
resource "google_compute_global_address" "private_ip_alloc" {
  for_each      = { for i, v in var.psa_subnets : i => v if var.psa_enable }
  name          = each.value.subnet_name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = split("/", each.value.subnet_ip)[0]
  prefix_length = split("/", each.value.subnet_ip)[1]
  network       = module.shared-vpc.network_name
}
 
locals {
  peering_ranges_names_list = [
    for v in google_compute_global_address.private_ip_alloc : v.name if var.psa_enable
  ]
}
 
resource "google_service_networking_connection" "private_service_connection" {
  count                   = var.psa_enable ? 1 : 0
  network                 = module.shared-vpc.network_name
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = local.peering_ranges_names_list
}
 
