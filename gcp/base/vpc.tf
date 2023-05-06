// 全体的なnetwork設定
resource "google_compute_network" "network" {
  name                    = local.vpc_network_name
  auto_create_subnetworks = false

  depends_on = [
    google_project_service.service,
  ]
}

resource "google_vpc_access_connector" "connector" {
  name          = "${local.vpc_network_name}-network-connetor"
  ip_cidr_range = "10.8.0.0/28"
  network       = google_compute_network.network.name
  region        = local.location
}

resource "google_compute_address" "egress_ip_address" {
  name   = "${local.vpc_network_name}-egress-ip-address"
  region = local.location

  depends_on = [
    google_project_service.service,
  ]
}

resource "google_compute_router" "router" {
  name    = "${local.vpc_network_name}-egress-router"
  region  = local.location
  network = google_compute_network.network.name
}

resource "google_compute_router_nat" "nat" {
  name                   = "${local.vpc_network_name}-egress-router-nat"
  router                 = google_compute_router.router.name
  region                 = google_compute_router.router.region
  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = google_compute_address.egress_ip_address.*.self_link

  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
