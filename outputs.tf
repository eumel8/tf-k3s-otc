output "k3s-url" {
  value = ["https://${var.rancher_host}.${var.rancher_domain}", "https://${opentelekomcloud_networking_floatingip_v2.eip.address}"]
}

output "wireguard-server-ip" {
  value = var.deploy_wireguard ? opentelekomcloud_networking_floatingip_v2.wireguard[0].address : null
}

output "wireguard-server-port" {
  value = var.deploy_wireguard ? var.wg_server_port : null
}

output "wireguard-server-key" {
  value = var.deploy_wireguard ? var.wg_server_public_key : null
}
