data "google_compute_zones" "zones" {
  region  = var.region
  project = var.project_id
}
 
locals {
  palo_interfaces = [
    {
      name      = "${var.name}-mgmt",
      interface = "management",
      public    = false,
      subnet    = var.mgmt_subnet
    },
    {
      name      = "${var.name}-outside",
      interface = "outside",
      public    = var.enable_public_ips,
      subnet    = var.outside_subnet
    },
    {
      name      = "${var.name}-inside",
      interface = "inside",
      public    = false,
      subnet    = var.inside_subnet
    }
  ]
}
 
locals {
  dmz_palo_interfaces = [
    {
      name      = "${var.name}-dmz",
      interface = "dmz",
      public    = false,
      subnet    = var.dmz_subnet
    }
  ]
}
 
resource "google_compute_address" "private-pa1" {
  for_each = { for i, v in local.palo_interfaces : local.palo_interfaces[i]["name"] => local.palo_interfaces[i] }
  project  = var.project_id
 
  name         = "${each.value.name}-private-pa1"
  address_type = "INTERNAL"
  subnetwork   = each.value.subnet
  region       = var.region
}
 
resource "google_compute_address" "private-pa2" {
  for_each = { for i, v in local.palo_interfaces : local.palo_interfaces[i]["name"] => local.palo_interfaces[i] }
  project  = var.project_id
 
  depends_on = [google_compute_address.private-pa1]
 
  name         = "${each.value.name}-private-pa2"
  address_type = "INTERNAL"
  subnetwork   = each.value.subnet
  region       = var.region
}
 
resource "google_compute_address" "dmz-private-pa1" {
  for_each = { for i, v in local.dmz_palo_interfaces : local.dmz_palo_interfaces[i]["name"] => v if var.enable_dmz_subnet != false }
  project  = var.project_id
 
  name         = "${each.value.name}-private-pa1"
  address_type = "INTERNAL"
  subnetwork   = each.value.subnet
  region       = var.region
}
 
resource "google_compute_address" "dmz-private-pa2" {
  for_each = { for i, v in local.dmz_palo_interfaces : local.dmz_palo_interfaces[i]["name"] => local.dmz_palo_interfaces[i] if var.enable_dmz_subnet != false }
  project  = var.project_id
 
  depends_on = [google_compute_address.dmz-private-pa1]
 
  name         = "${each.value.name}-private-pa2"
  address_type = "INTERNAL"
  subnetwork   = each.value.subnet
  region       = var.region
}
 
resource "google_compute_address" "public-pa1" {
  for_each = { for v in local.palo_interfaces : v["name"] => v if v.public == true }
  project  = var.project_id
 
  name         = "${each.value.name}-public-pa1"
  address_type = "EXTERNAL"
  region       = var.region
}
 
resource "google_compute_address" "public-pa2" {
  for_each = { for v in local.palo_interfaces : v["name"] => v if v.public == true }
  project  = var.project_id
 
  depends_on = [google_compute_address.public-pa1]
 
  name         = "${each.value.name}-public-pa2"
  address_type = "EXTERNAL"
  region       = var.region
}
 
locals {
  metadata = {
    type               = "dhcp-client",
    serial-port-enable = true,
    ssh-keys           = "admin:${var.public_key}"
  }
}
 
resource "google_compute_instance" "vmseries-pa1" {
  name   = "${var.name}-1"
  tags   = var.tags
  labels = var.labels
  zone   = data.google_compute_zones.zones.names[0]
 
  machine_type              = var.machine_type
  project                   = var.project_id
  can_ip_forward            = true
  allow_stopping_for_update = true
 
  metadata = local.metadata
 
  network_interface {
    subnetwork = local.palo_interfaces[0]["subnet"]
    network_ip = google_compute_address.private-pa1[local.palo_interfaces[0]["name"]].address
  }
 
  dynamic "network_interface" {
    for_each = var.enable_public_ips != false ? [1] : []
    content {
      subnetwork = local.palo_interfaces[1]["subnet"]
      network_ip = google_compute_address.private-pa1[local.palo_interfaces[1]["name"]].address
 
      access_config {
        nat_ip = google_compute_address.public-pa1[local.palo_interfaces[1]["name"]].address
      }
    }
  }
 
  dynamic "network_interface" {
    for_each = var.enable_public_ips == false ? [1] : []
    content {
      subnetwork = local.palo_interfaces[1]["subnet"]
      network_ip = google_compute_address.private-pa1[local.palo_interfaces[1]["name"]].address
    }
  }
 
  network_interface {
    subnetwork = local.palo_interfaces[2]["subnet"]
    network_ip = google_compute_address.private-pa1[local.palo_interfaces[2]["name"]].address
  }
 
  dynamic "network_interface" {
    for_each = var.enable_dmz_subnet != false ? [1] : []
    content {
      subnetwork = local.dmz_palo_interfaces[0]["subnet"]
      network_ip = google_compute_address.dmz-private-pa1[local.dmz_palo_interfaces[0]["name"]].address
    }
  }
 
  boot_disk {
    initialize_params {
      image  = var.image_url
      type   = var.disk_type
      size   = var.disk_size
      labels = var.labels
    }
  }
}
 
resource "google_compute_instance" "vmseries-pa2" {
  name = "${var.name}-2"
 
  depends_on = [google_compute_instance.vmseries-pa1]
 
  tags   = var.tags
  labels = var.labels
  zone   = data.google_compute_zones.zones.names[1]
 
  machine_type              = var.machine_type
  project                   = var.project_id
  can_ip_forward            = true
  allow_stopping_for_update = true
  metadata                  = local.metadata
 
  network_interface {
    subnetwork = local.palo_interfaces[0]["subnet"]
    network_ip = google_compute_address.private-pa2[local.palo_interfaces[0]["name"]].address
  }
 
  dynamic "network_interface" {
    for_each = var.enable_public_ips != false ? [1] : []
    content {
      subnetwork = local.palo_interfaces[1]["subnet"]
      network_ip = google_compute_address.private-pa2[local.palo_interfaces[1]["name"]].address
 
      access_config {
        nat_ip = google_compute_address.public-pa2[local.palo_interfaces[1]["name"]].address
      }
    }
  }
 
  dynamic "network_interface" {
    for_each = var.enable_public_ips == false ? [1] : []
    content {
      subnetwork = local.palo_interfaces[1]["subnet"]
      network_ip = google_compute_address.private-pa2[local.palo_interfaces[1]["name"]].address
    }
  }
 
  network_interface {
    subnetwork = local.palo_interfaces[2]["subnet"]
    network_ip = google_compute_address.private-pa2[local.palo_interfaces[2]["name"]].address
  }
  dynamic "network_interface" {
    for_each = var.enable_dmz_subnet != false ? [1] : []
    content {
      subnetwork = local.dmz_palo_interfaces[0]["subnet"]
      network_ip = google_compute_address.dmz-private-pa2[local.dmz_palo_interfaces[0]["name"]].address
    }
  }
 
  boot_disk {
    initialize_params {
      image  = var.image_url
      type   = var.disk_type
      size   = var.disk_size
      labels = var.labels
    }
  }
}
 
data "google_compute_subnetwork" "inside" {
  name   = element(split("/", var.inside_subnet), length(split("/", var.inside_subnet)) - 1)
  region = var.region
}
 
data "google_compute_subnetwork" "outside" {
  name   = element(split("/", var.outside_subnet), length(split("/", var.outside_subnet)) - 1)
  region = var.region
}
 
data "google_compute_subnetwork" "dmz" {
  count  = var.enable_dmz_subnet ? 1 : 0
  name   = element(split("/", var.dmz_subnet), length(split("/", var.dmz_subnet)) - 1)
  region = var.region
}
 
locals {
  outside_network = data.google_compute_subnetwork.outside.network
  inside_network  = data.google_compute_subnetwork.inside.network
  dmz_network     = var.enable_dmz_subnet == false ? "" : data.google_compute_subnetwork.dmz[0].network
  inside_spoke_data = {
    "${var.name}-1-inside" = {
      ip_address   = google_compute_address.private-pa1[local.palo_interfaces[2]["name"]].address
      vm_self_link = google_compute_instance.vmseries-pa1.self_link
      region       = var.region
    }
    "${var.name}-2-inside" = {
      ip_address   = google_compute_address.private-pa2[local.palo_interfaces[2]["name"]].address
      vm_self_link = google_compute_instance.vmseries-pa2.self_link
      region       = var.region
    }
  }
  outside_spoke_data = {
    "${var.name}-1-outside" = {
      ip_address   = google_compute_address.private-pa1[local.palo_interfaces[1]["name"]].address
      vm_self_link = google_compute_instance.vmseries-pa1.self_link
      region       = var.region
    }
    "${var.name}-2-outside" = {
      ip_address   = google_compute_address.private-pa2[local.palo_interfaces[1]["name"]].address
      vm_self_link = google_compute_instance.vmseries-pa2.self_link
      region       = var.region
    }
  }
  dmz_spoke_data = var.enable_dmz_subnet ? {
    "${var.name}-1-dmz" = {
      ip_address   = google_compute_address.dmz-private-pa1[local.dmz_palo_interfaces[0]["name"]].address
      vm_self_link = google_compute_instance.vmseries-pa1.self_link
      region       = var.region
    }
    "${var.name}-2-dmz" = {
      ip_address   = google_compute_address.dmz-private-pa2[local.dmz_palo_interfaces[0]["name"]].address
      vm_self_link = google_compute_instance.vmseries-pa2.self_link
      region       = var.region
    }
  } : {}
}
 