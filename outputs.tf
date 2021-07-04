output "rke2-url" {
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

output "k3s-nodes" {
  value = [opentelekomcloud_compute_instance_v2.k3s-server-1.access_ip_v4, opentelekomcloud_compute_instance_v2.k3s-server-2.access_ip_v4]
}
