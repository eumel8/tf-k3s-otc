output "k3s-url" {
  value = ["https://${var.rancher_host}.${var.rancher_domain}", "https://${opentelekomcloud_networking_floatingip_v2.eip.address}"]
}
