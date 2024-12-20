variable "project_id" {
  type        = string
  description = "GCP project ID where to run the TF code"
}
 
variable "image_url" {
  type        = string
  description = "The image URL for the firewall."
  default     = "https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries-bundle2-913"
}
 
variable "machine_type" {
  type        = string
  description = "Machine type for the vmseries instances."
  default     = "n2-standard-8"
}
 
variable "disk_type" {
  type        = string
  description = "Type of disk for the firewall"
  default     = "pd-ssd"
}
 
variable "public_key" {
  description = "Vmseries public SSH key."
  type        = string
}
 
variable "mgmt_subnet" {
  description = "The Management Subnet used for the VM Series Palo Alto firewalls"
  type        = string
}
 
variable "outside_subnet" {
  description = "The Outside Subnet used for the VM Series Palo Alto firewalls"
  type        = string
}
 
variable "inside_subnet" {
  description = "The Inside Subnet used for the VM Series Palo Alto firewalls"
  type        = string
}
 
variable "dmz_subnet" {
  description = "Optional dmz subnet used for the VM Series Palo Alto firewalls"
  type        = string
  default     = ""
}
 
variable "enable_dmz_subnet" {
  description = "Optional dmz subnet used for the VM Series Palo Alto firewalls"
  type        = bool
  default     = false
}
 
variable "enable_public_ips" {
  description = "Optional publice IPs used for the VM Series Palo Alto firewalls outside interface"
  type        = bool
  default     = false
}
 
variable "tags" {
  description = "Network tags to assign to Palo Alto Firewalls"
  type        = list(string)
  default     = []
}
 
variable "labels" {
  description = "Labels to assign to Palo Alto Firewalls"
  default     = {}
  type        = map(any)
}
 
variable "region" {
  description = "Region to deploy PA firewall into"
  type        = string
}
 
variable "name" {
  description = "Name prefix for Palo Alto firewall"
  type        = string
}
 
variable "disk_size" {
  description = "Disk size in GB for Palo Alto firewall"
  type        = number
  default     = 250
}
