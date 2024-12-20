variable "project_id" {
  description = "Project to run admin commands against"
  type        = string
}
 
variable "environment" {
  description = "environment key currently running as"
  type        = string
}
 
variable "vpc_suffix" {
  description = "VPC name suffix"
  type        = string
}
 
variable "parent_cidr_map" {
  type        = map(any)
  description = "The super cidr to use for the environment.  This is the parent cidr for Infoblox"
}
 
# variable "psa_enable" {
#   type        = bool
#   description = "Bool variable to enable/disable PSA"
#   default     = true
# }
 
# variable "psa_subnets" {
#   type        = list(any)
#   description = "The list of prefix lengths to use to provision subnets for Private service access"
#   default     = []
# }
 
variable "vpc_subnets" {
  type        = list(any)
  description = "The list of prefix lengths to use to provision subnets for Private service access"
  default     = []
}
 
# variable "firewall_rules" {
#   type        = list(any)
#   default     = []
#   description = "A list of default firewall rules to be applied to entire VPC"
# }
 
# variable "vpc_routes" {
#   type        = list(any)
#   description = "A list of route configurations to be applied to the vpc"
#   default     = []
# }
 
variable "subnets" {
  type        = list(any)
  description = "List of maps containing subnet information for VPC"
  default     = []
}
 
# variable "shared_vpc_host_enable" {
#   type        = bool
#   description = "Enable/Disable addition of google_compute_shared_vpc_host_project resource"
#   default     = true
# }
 
