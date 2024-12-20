variable "project_id" {
  description = "Project to run admin commands against"
  type        = string
}
 
# variable "infoblox_vpc_netview" {
#   type        = string
#   description = "Netview used in InfoBlox"
# }
 
variable "subnet_map" {
  type        = any
  description = "Map containing all VPC subnets"
}
# variable "parent_subnets_map" {
#   type        = any
#   description = "Map containing all parent VPC subnets"
# }
 
variable "environment" {
  description = "environment key currently running as"
  type        = string
}
 
variable "vpc_suffix" {
  description = "VPC name suffix"
  type        = string
}
 
variable "firewall_rules" {
  type        = list(any)
  default     = []
  description = "A list of default firewall rules to be applied to entire VPC"
}
 
variable "vpc_routes" {
  type        = list(any)
  description = "A list of route configurations to be applied to the vpc"
  default     = []
}
 
# variable "shared_vpc_host_enable" {
#   type        = bool
#   description = "Enable/Disable addition of google_compute_shared_vpc_host_project resource"
# }
 
# variable "routers" {
#   type        = list(string)
#   description = "Map of cloud routers used to build cloud routers"
# }
 
# variable "mdr_asn" {
#   type        = number
#   description = "MDR ASN to use for VPC"
# }
 
variable "partner_interconnect_attachments" {
  type        = map(any)
  description = "Partner interconnect config"
}
 
# variable "mdr_interconnects" {
#   type        = map(any)
#   description = "Partner interconnect config"
# }
 
# variable "mdr_routers" {
#   type        = list(string)
#   description = "Map of cloud routers used to build cloud routers"
# }
 
variable "bck1411_router_map" {
  description = "BMS/Backup Cloud Router Map Configuration"
  type        = map(any)
}
 
# variable "dns_zones_googleapis" {
#   type        = any
#   description = "Map containing data for PGA Zones/Records"
# }
 
 
###
### Palo Alto firewalls variables
###
 
variable "image_url" {
  type        = string
  description = "Palo Alto image url"
}
 
variable "panos_v1016h6" {
  type        = string
  description = "Palo Alto version 10.1.6(h6) image url"
}
 
variable "disk_size" {
  type        = number
  description = "Size in GB of Palo Alto firewalls disk"
}
 
variable "machine_type" {
  type        = string
  description = "Machine type for Palo Alto firewall"
}
 
variable "disk_type" {
  type        = string
  description = "Disk type for Palo Alto firewall"
}
 
variable "public_key" {
  type        = string
  description = "Public SSH key used to access Palo Alto firewall"
}
 
# variable "forwarding_domains" {
#   type = any
# }
 
# variable "target_name_server_addresses" {
#   type = list(string)
# }
 
# variable "target_vpc_networks" {
#   type = list(map(string))
# }
 
variable "router_map" {
  description = "Cloud Router Map Configuration"
  type        = map(any)
}
 
# variable "mig_router_map" {
#   description = "Cloud Router Map Configuration"
#   type        = map(any)
# }
 
# variable "bck_ic_map" {
#   description = "Interconnect Map Configuration"
#   type        = map(any)
# }
 
# variable "ic_mig_map" {
#   description = "Interconnect Map Configuration"
#   type        = map(any)
# }
 
# variable "router_interfaces_map" {
#   description = "Cloud Router Interfaces Configuration"
#   type        = map(any)
# }
 
# variable "wan_bgp_map" {
#   description = "Cloud Router BGP peering Configuration"
#   type        = map(any)
# }
 
variable "vpn_config" {
  description = "VPN configuration"
  type        = any
}
 
variable "vpn_psk" {
  description = "PSK used for VPN tunnels"
  type        = string
  sensitive   = true
}
 
# variable "private_ip_address" {
#   description = "Cloud Router interface IP address"
#   type        = string
# }
 
# variable "subnetwork" {
#   description = "Subnet Self-Link"
#   type        = string
# }
 
# variable "redundant_interface" {
#   description = "Cloud Router Secondary interface name"
#   type        = string
# }
 
# variable "org_admin_email" {
#   type        = string
#   description = "email address for org administrator"
# }
 
variable "org_id" {
  description = "Numeric ID of Organization"
  type        = string
}
 
# variable "host_networking_service_accounts" {
#   description = "List of host-networking service accounts that required shared_vpc admin role on org"
#   type        = list(string)
#   default     = []
# }