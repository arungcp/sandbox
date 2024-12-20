####### VPC Networks
  # Inside VPC
    module "inside_vpc" {
      #source                 = "app.terraform.io/dnb-core/dnb_gcp_shared_vpc_generic/google"
      source                 = "./modules/gcp_shared"
      version                = "1.2.8"
      project_id             = var.project_id
      environment            = var.environment
      vpc_suffix             = "${var.vpc_suffix}-inside"
      parent_cidr_map        = { this = "dumb", value = 0 }
      vpc_subnets            = var.subnet_map["vpc_subnets_map"]
      psa_subnets            = var.subnet_map["psa_subnets_map"]
      firewall_rules         = var.subnet_map["vpc_firewall_rules"]
      vpc_routes             = []
      shared_vpc_host_enable = false
      psa_enable             = true
      depends_on             = [google_project_service.service_networking]
    }
 
  # MGMT VPC
    module "mgmt_vpc" {
      #source                 = "app.terraform.io/dnb-core/dnb_gcp_shared_vpc_generic/google"
      source                 = "./modules/gcp_shared"
      version                = "1.2.8"
      project_id             = var.project_id
      environment            = var.environment
      vpc_suffix             = "${var.vpc_suffix}-mgmt"
      parent_cidr_map        = { this = "dumb", value = 0 }
      vpc_subnets            = var.subnet_map["mgmt_subnets_map"]
      psa_subnets            = []
      firewall_rules         = var.subnet_map["mgmt_firewall_rules"]
      vpc_routes             = var.subnet_map["mgmt_routes"]
      shared_vpc_host_enable = false
      psa_enable             = false
      depends_on             = [google_project_service.service_networking]
    }
 
  # Outside VPC
    module "outside_vpc" {
      #source      = "app.terraform.io/dnb-core/dnb_gcp_shared_vpc_generic/google"
      source                 = "./modules/gcp_shared"
      version     = "1.2.8"
      project_id  = var.project_id
      environment = var.environment
      vpc_suffix  = "${var.vpc_suffix}-outside"
      # Specific value reference Fix later
      parent_cidr_map        = { this = "dumb", value = 0 }
      vpc_subnets            = var.subnet_map["outside_subnets_map"]
      psa_subnets            = []
      firewall_rules         = var.subnet_map["outside_firewall_rules"]
      vpc_routes             = var.subnet_map["outside_routes"]
      shared_vpc_host_enable = false
      psa_enable             = false
      depends_on             = [google_project_service.service_networking]
    }
 
  # WAN VPC
    module "wan_vpc" {
      #source                 = "app.terraform.io/dnb-core/dnb_gcp_shared_vpc_generic/google"
      source                 = "./modules/gcp_shared"
      version                = "1.2.8"
      project_id             = var.project_id
      environment            = var.environment
      vpc_suffix             = "${var.vpc_suffix}-wan"
      parent_cidr_map        = { this = "dumb", value = 0 }
      vpc_subnets            = var.subnet_map["wan_subnets_map"]
      psa_subnets            = []
      psa_enable             = false
      firewall_rules         = var.subnet_map["wan_firewall_rules"]
      vpc_routes             = []
      shared_vpc_host_enable = false
    }
 
 
 
  # VPC peering
 
    # # Peer WAN with Mgmt
    #   resource "google_compute_network_peering" "prodwan-to-mgmt" {
    #     name                 = "prodwan-to-mgmt"
    #     network              = module.wan_vpc.network_self_link
    #     peer_network         = module.mgmt_vpc.network_self_link
    #     export_custom_routes = true
    #     import_custom_routes = false
    #   }
 
    # # Peer Mgmt with WAN
    #   resource "google_compute_network_peering" "mgmt-to-prodwan" {
    #     name                 = "mgmt-to-prodwan"
    #     network              = module.mgmt_vpc.network_self_link
    #     peer_network         = module.wan_vpc.network_self_link
    #     export_custom_routes = false
    #     import_custom_routes = true
    #   }
 
####### Palo Alto Firewalls
  # Palo Alto firewalls (UE4)
      module "ditc-ue4-prod-pa" {
        #source            = "app.terraform.io/dnb-core/dnb_palo_alto_vmseries/google"
        source            = "./modules/palo_VM"
        name              = "ditc-ue4-prod-pa"
        version           = "1.2.7"
        project_id        = var.project_id
        image_url         = var.panos_v1016h6
        machine_type      = var.machine_type
        disk_type         = var.disk_type
        disk_size         = var.disk_size
        mgmt_subnet       = module.mgmt_vpc.subnets["us-east4/ditc-useast4-nvasubnet-mgmt"].name
        outside_subnet    = module.outside_vpc.subnets["us-east4/ditc-useast4-nvasubnet-outside"].name
        inside_subnet     = module.inside_vpc.subnets["us-east4/ditc-useast4-nvasubnet"].name
        dmz_subnet        = module.wan_vpc.subnets["us-east4/ditc-useast4-nvasubnet-wan"].name
        enable_dmz_subnet = true
        enable_public_ips = true
        tags              = ["palo-mgmt", "palo-dataplane"]
        region            = "us-east4"
        public_key        = var.public_key
        labels = {
          name            = "ditc-ue4-prod-pa"
          drn             = "3937"
          dnb_environment = "production"
        }
      }
 
    # # Cloud NAT to provide internet access to Mgmt interface (UE4)
    # module "mgmt_cloud_nat_ue4" {
    #   source                             = "app.terraform.io/dnb-core/dnb_cloud_nat/google"
    #   version                            = "0.0.3"
    #   name                               = "${var.vpc_suffix}-ue4-mgmt-nat"
    #   project_id                         = var.project_id
    #   region                             = "us-east4"
    #   router                             = "${var.vpc_suffix}-ue4-mgmt-cr"
    #   nat_ip_allocate_option             = "AUTO_ONLY"
    #   source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
    #   min_ports_per_vm                   = 8192
    #   network                            = module.mgmt_vpc.network_name
    #   num_of_ip_addresses                = 0
    # }
 
  # Palo Alto firewalls (UC1)
    module "ditc-uc1-prod-pa" {
      #source = "app.terraform.io/dnb-core/dnb_palo_alto_vmseries/google"
      source            = "./modules/palo_VM"
      name              = "ditc-uc1-prod-pa"
      version           = "1.2.7"
      project_id        = var.project_id
      image_url         = var.panos_v1016h6
      machine_type      = var.machine_type
      disk_type         = var.disk_type
      disk_size         = var.disk_size
      mgmt_subnet       = module.mgmt_vpc.subnets["us-central1/ditc-uscentral1-nvasubnet-mgmt"].name
      outside_subnet    = module.outside_vpc.subnets["us-central1/ditc-uscentral1-nvasubnet-outside"].name
      inside_subnet     = module.inside_vpc.subnets["us-central1/ditc-uscentral1-nvasubnet"].name
      dmz_subnet        = module.wan_vpc.subnets["us-central1/ditc-uscentral1-nvasubnet-wan"].name
      enable_dmz_subnet = true
      enable_public_ips = true
      tags              = ["palo-mgmt", "palo-dataplane"]
      region            = "us-central1"
      public_key        = var.public_key
      labels = {
        name            = "ditc-uc1-prod-pa"
        drn             = "3937"
        dnb_environment = "production"
      }
    }
