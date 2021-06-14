
########### 
# VPC part
########### 
resource "opentelekomcloud_vpc_v1" "vpc" {
  name   = var.environment
  cidr   = var.vpc_cidr
  shared = true
}

resource "opentelekomcloud_vpc_subnet_v1" "subnet" {
  name          = var.environment
  vpc_id        = opentelekomcloud_vpc_v1.vpc.id
  cidr          = var.subnet_cidr
  gateway_ip    = var.subnet_gateway_ip
  primary_dns   = var.subnet_primary_dns
  secondary_dns = var.subnet_secondary_dns
}

########### 
# ELB part
########### 
resource "opentelekomcloud_networking_floatingip_v2" "eip" {
  pool    = "admin_external_net"
  port_id = opentelekomcloud_lb_loadbalancer_v2.lb.vip_port_id
}

resource "opentelekomcloud_lb_loadbalancer_v2" "lb" {
  name          = "${var.environment}-lb"
  vip_subnet_id = opentelekomcloud_vpc_subnet_v1.subnet.subnet_id
}

resource "opentelekomcloud_lb_listener_v2" "listener_80" {
  protocol         = "TCP"
  name             = "${var.environment}-listener_80"
  protocol_port    = 80
  loadbalancer_id  = opentelekomcloud_lb_loadbalancer_v2.lb.id
}

resource "opentelekomcloud_lb_listener_v2" "listener_443" {
  protocol         = "TCP"
  name             = "${var.environment}-listener_443"
  protocol_port    = 443
  loadbalancer_id  = opentelekomcloud_lb_loadbalancer_v2.lb.id
}

resource "opentelekomcloud_lb_listener_v2" "listener_6443" {
  protocol         = "TCP"
  name             = "${var.environment}-listener_6443"
  protocol_port    = 6443
  loadbalancer_id  = opentelekomcloud_lb_loadbalancer_v2.lb.id
}

resource "opentelekomcloud_lb_listener_v2" "listener_9345" {
  protocol         = "TCP"
  name             = "${var.environment}-listener_9345"
  protocol_port    = 9345
  loadbalancer_id  = opentelekomcloud_lb_loadbalancer_v2.lb.id
}

resource "opentelekomcloud_lb_pool_v2" "pool_80" {
  protocol    = "TCP"
  name        = "${var.environment}-pool_80"
  lb_method   = "ROUND_ROBIN"
  listener_id = opentelekomcloud_lb_listener_v2.listener_80.id
}

resource "opentelekomcloud_lb_pool_v2" "pool_443" {
  protocol    = "TCP"
  name        = "${var.environment}-pool_443"
  lb_method   = "ROUND_ROBIN"
  listener_id = opentelekomcloud_lb_listener_v2.listener_443.id
}
 
resource "opentelekomcloud_lb_pool_v2" "pool_6443" {
  protocol    = "TCP"
  name        = "${var.environment}-pool_6443"
  lb_method   = "ROUND_ROBIN"
  listener_id = opentelekomcloud_lb_listener_v2.listener_6443.id
}

resource "opentelekomcloud_lb_pool_v2" "pool_9345" {
  protocol    = "TCP"
  name        = "${var.environment}-pool_9345"
  lb_method   = "ROUND_ROBIN"
  listener_id = opentelekomcloud_lb_listener_v2.listener_9345.id
}
 
resource "opentelekomcloud_lb_monitor_v2" "monitor_80" {
  pool_id        = opentelekomcloud_lb_pool_v2.pool_80.id
  type           = "TCP"
  delay          = 5
  timeout        = 5
  max_retries    = 10
}

resource "opentelekomcloud_lb_monitor_v2" "monitor_443" {
  pool_id        = opentelekomcloud_lb_pool_v2.pool_443.id
  type           = "TCP"
  delay          = 5
  timeout        = 5
  max_retries    = 10
}
 
resource "opentelekomcloud_lb_monitor_v2" "monitor_6443" {
  pool_id        = opentelekomcloud_lb_pool_v2.pool_6443.id
  type           = "TCP"
  delay          = 5
  timeout        = 5
  max_retries    = 10
}

resource "opentelekomcloud_lb_monitor_v2" "monitor_9345" {
  pool_id        = opentelekomcloud_lb_pool_v2.pool_9345.id
  type           = "TCP"
  delay          = 5
  timeout        = 5
  max_retries    = 10
}

# server 1
resource "opentelekomcloud_lb_member_v2" "member_80_1" {
  address       = opentelekomcloud_compute_instance_v2.rke2-server-1.access_ip_v4
  protocol_port = 80
  pool_id       = opentelekomcloud_lb_pool_v2.pool_80.id
  subnet_id     = opentelekomcloud_vpc_subnet_v1.subnet.subnet_id
}

resource "opentelekomcloud_lb_member_v2" "member_443_1" {
  address       = opentelekomcloud_compute_instance_v2.rke2-server-1.access_ip_v4
  protocol_port = 443
  pool_id       = opentelekomcloud_lb_pool_v2.pool_443.id
  subnet_id     = opentelekomcloud_vpc_subnet_v1.subnet.subnet_id
}

resource "opentelekomcloud_lb_member_v2" "member_6443_1" {
  address       = opentelekomcloud_compute_instance_v2.rke2-server-1.access_ip_v4
  protocol_port = 6443
  pool_id       = opentelekomcloud_lb_pool_v2.pool_6443.id
  subnet_id     = opentelekomcloud_vpc_subnet_v1.subnet.subnet_id
}

resource "opentelekomcloud_lb_member_v2" "member_9345_1" {
  address       = opentelekomcloud_compute_instance_v2.rke2-server-1.access_ip_v4
  protocol_port = 9345
  pool_id       = opentelekomcloud_lb_pool_v2.pool_9345.id
  subnet_id     = opentelekomcloud_vpc_subnet_v1.subnet.subnet_id
}
 
# server 2
resource "opentelekomcloud_lb_member_v2" "member_80_2" {
  address       = opentelekomcloud_compute_instance_v2.rke2-server-2.access_ip_v4
  protocol_port = 80
  pool_id       = opentelekomcloud_lb_pool_v2.pool_80.id
  subnet_id     = opentelekomcloud_vpc_subnet_v1.subnet.subnet_id
}

resource "opentelekomcloud_lb_member_v2" "member_443_2" {
  address       = opentelekomcloud_compute_instance_v2.rke2-server-2.access_ip_v4
  protocol_port = 443
  pool_id       = opentelekomcloud_lb_pool_v2.pool_443.id
  subnet_id     = opentelekomcloud_vpc_subnet_v1.subnet.subnet_id
}

resource "opentelekomcloud_lb_member_v2" "member_6443_2" {
  address       = opentelekomcloud_compute_instance_v2.rke2-server-2.access_ip_v4
  protocol_port = 6443
  pool_id       = opentelekomcloud_lb_pool_v2.pool_6443.id
  subnet_id     = opentelekomcloud_vpc_subnet_v1.subnet.subnet_id
}

resource "opentelekomcloud_lb_member_v2" "member_9345_2" {
  address       = opentelekomcloud_compute_instance_v2.rke2-server-2.access_ip_v4
  protocol_port = 9345
  pool_id       = opentelekomcloud_lb_pool_v2.pool_9345.id
  subnet_id     = opentelekomcloud_vpc_subnet_v1.subnet.subnet_id
}

# server 3
resource "opentelekomcloud_lb_member_v2" "member_80_3" {
  address       = opentelekomcloud_compute_instance_v2.rke2-server-3.access_ip_v4
  protocol_port = 80
  pool_id       = opentelekomcloud_lb_pool_v2.pool_80.id
  subnet_id     = opentelekomcloud_vpc_subnet_v1.subnet.subnet_id
}

resource "opentelekomcloud_lb_member_v2" "member_443_3" {
  address       = opentelekomcloud_compute_instance_v2.rke2-server-3.access_ip_v4
  protocol_port = 443
  pool_id       = opentelekomcloud_lb_pool_v2.pool_443.id
  subnet_id     = opentelekomcloud_vpc_subnet_v1.subnet.subnet_id
}

resource "opentelekomcloud_lb_member_v2" "member_6443_3" {
  address       = opentelekomcloud_compute_instance_v2.rke2-server-3.access_ip_v4
  protocol_port = 6443
  pool_id       = opentelekomcloud_lb_pool_v2.pool_6443.id
  subnet_id     = opentelekomcloud_vpc_subnet_v1.subnet.subnet_id
}

resource "opentelekomcloud_lb_member_v2" "member_9345_3" {
  address       = opentelekomcloud_compute_instance_v2.rke2-server-3.access_ip_v4
  protocol_port = 9345
  pool_id       = opentelekomcloud_lb_pool_v2.pool_9345.id
  subnet_id     = opentelekomcloud_vpc_subnet_v1.subnet.subnet_id
}

########### 
# DNS part 
########### 

resource "opentelekomcloud_dns_zone_v2" "dns" {
  count       = var.create_dns ? 1 : 0
  name        = "${var.rancher_domain}."
  email       = var.admin_email
  description = "tf managed zone"
  ttl         = 300
  type        = "public"
}

resource "opentelekomcloud_dns_recordset_v2" "public_record" {
  count       = var.create_dns ? 1 : 0
  zone_id     = opentelekomcloud_dns_zone_v2.dns[0].id
  name        = "${var.rancher_host}.${var.rancher_domain}."
  description = "tf managed zone"
  type        = "A"
  ttl         = 300
  records     = [ opentelekomcloud_networking_floatingip_v2.eip.address ]
}

########### 
# ECS part
########### 

data "template_file" "rke2_server" {
  template = file("${path.module}/files/rke2_server")
  vars = {
    token                = var.token
    node_status          = "0"
    admin_email          = var.admin_email
    rancher_host         = var.rancher_host
    rancher_domain       = var.rancher_domain
    rancher_version      = var.rancher_version
    rke2_version         = var.rke2_version
    cert-manager_version = var.cert-manager_version
  }
}

data "template_file" "rke2_node" {
  template = file("${path.module}/files/rke2_node")
  vars = {
    token                = var.token
    rancher_host         = var.rancher_host
    rancher_domain       = var.rancher_domain
    rke2_version         = var.rke2_version
    cert-manager_version = var.cert-manager_version
  }
}

data "opentelekomcloud_images_image_v2" "image-1" {
  name        = var.image_name_server-1
  most_recent = true
}

data "opentelekomcloud_images_image_v2" "image-2" {
  name        = var.image_name_server-2
  most_recent = true
}
 
# Secgroup part (ECS)
resource "opentelekomcloud_networking_secgroup_v2" "rke2-server-secgroup" {
  description = "K3S Server Group"
  name        = "${var.environment}-secgroup"
}
 
resource "opentelekomcloud_networking_secgroup_rule_v2" "sg_rke2_all_out" {
  description       = "Rancher/K3S accept all traffic"
  direction         = "egress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = opentelekomcloud_networking_secgroup_v2.rke2-server-secgroup.id
}
 
resource "opentelekomcloud_networking_secgroup_rule_v2" "sg_rke2_80_in" {
  description       = "Rancher HTTP ELB network"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "100.125.0.0/16"
  security_group_id = opentelekomcloud_networking_secgroup_v2.rke2-server-secgroup.id
}
 
resource "opentelekomcloud_networking_secgroup_rule_v2" "sg_rke2_443_in" {
  description       = "Rancher HTTPS ELB network"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "100.125.0.0/16"
  security_group_id = opentelekomcloud_networking_secgroup_v2.rke2-server-secgroup.id
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "sg_rke2_443_in_self" {
  description       = "Rancher HTTPS internal"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_group_id   = opentelekomcloud_networking_secgroup_v2.rke2-server-secgroup.id
  security_group_id = opentelekomcloud_networking_secgroup_v2.rke2-server-secgroup.id
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "sg_rke2_2329_in_self" {
  description       = "etcd client internal"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 2379
  port_range_max    = 2379
  remote_group_id   = opentelekomcloud_networking_secgroup_v2.rke2-server-secgroup.id
  security_group_id = opentelekomcloud_networking_secgroup_v2.rke2-server-secgroup.id
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "sg_rke2_2380_in_self" {
  description       = "etcd peer internal"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 2380
  port_range_max    = 2380
  remote_group_id   = opentelekomcloud_networking_secgroup_v2.rke2-server-secgroup.id
  security_group_id = opentelekomcloud_networking_secgroup_v2.rke2-server-secgroup.id
}

 
resource "opentelekomcloud_networking_secgroup_rule_v2" "sg_rke2_6443_in" {
  description       = "Kube API ELB network"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_ip_prefix  = "100.125.0.0/16"
  security_group_id = opentelekomcloud_networking_secgroup_v2.rke2-server-secgroup.id
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "sg_rke2_6443_in_self" {
  description       = "Kube API internal"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_group_id   = opentelekomcloud_networking_secgroup_v2.rke2-server-secgroup.id
  security_group_id = opentelekomcloud_networking_secgroup_v2.rke2-server-secgroup.id
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "sg_rke2_8472_in" {
  description       = "Flannel VXLAN"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 8472
  port_range_max    = 8472
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = opentelekomcloud_networking_secgroup_v2.rke2-server-secgroup.id
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "sg_rke2_9345_in" {
  description       = "RKE2 ELB network"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 9345
  port_range_max    = 9345
  remote_ip_prefix  = "100.125.0.0/16"
  security_group_id = opentelekomcloud_networking_secgroup_v2.rke2-server-secgroup.id
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "sg_rke2_9345_in_self" {
  description       = "RKE2 internal"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 9345
  port_range_max    = 9345
  remote_group_id   = opentelekomcloud_networking_secgroup_v2.rke2-server-secgroup.id
  security_group_id = opentelekomcloud_networking_secgroup_v2.rke2-server-secgroup.id
}


resource "opentelekomcloud_networking_secgroup_rule_v2" "sg_rke2_9796_in" {
  description       = "Prometheus Node Exporter"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 9796
  port_range_max    = 9796
  remote_group_id   = opentelekomcloud_networking_secgroup_v2.rke2-server-secgroup.id
  security_group_id = opentelekomcloud_networking_secgroup_v2.rke2-server-secgroup.id
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "sg_rke2_10250_in" {
  description       = "Kubelet"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10250
  port_range_max    = 10250
  remote_group_id   = opentelekomcloud_networking_secgroup_v2.rke2-server-secgroup.id
  security_group_id = opentelekomcloud_networking_secgroup_v2.rke2-server-secgroup.id
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "sg_rke2_30000_in" {
  description       = "Node ports"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 30000
  port_range_max    = 32767
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = opentelekomcloud_networking_secgroup_v2.rke2-server-secgroup.id
}

# ssh key part
resource "opentelekomcloud_compute_keypair_v2" "rke2-server-key" {
  name       = "${var.environment}-key"
  public_key = var.public_key
}

# ECS part (instances)
resource "opentelekomcloud_compute_instance_v2" "rke2-server-1" {
  name              = "${var.environment}-server-1"
  availability_zone = var.availability_zone1
  flavor_id         = var.flavor_id
  key_pair          = opentelekomcloud_compute_keypair_v2.rke2-server-key.name
  security_groups   = ["${var.environment}-secgroup"]
  user_data         = data.template_file.rke2_server.rendered
  power_state       = var.power_state
  network {
    uuid = opentelekomcloud_vpc_subnet_v1.subnet.id
  }
  block_device {
    boot_index            = 0
    source_type           = "image"
    destination_type      = "volume"
    uuid                  = data.opentelekomcloud_images_image_v2.image-1.id
    delete_on_termination = true
    volume_size           = 30
  }
}

resource "opentelekomcloud_compute_instance_v2" "rke2-server-2" {
  name              = "${var.environment}-server-2"
  availability_zone = var.availability_zone2
  flavor_id         = var.flavor_id
  key_pair          = opentelekomcloud_compute_keypair_v2.rke2-server-key.name
  security_groups   = ["${var.environment}-secgroup"]
  user_data         = data.template_file.rke2_node.rendered
  power_state       = var.power_state
  network {
    uuid = opentelekomcloud_vpc_subnet_v1.subnet.id
  }
  block_device {
    boot_index            = 0
    source_type           = "image"
    destination_type      = "volume"
    uuid                  = data.opentelekomcloud_images_image_v2.image-2.id
    delete_on_termination = true
    volume_size           = 30
  }
}

resource "opentelekomcloud_compute_instance_v2" "rke2-server-3" {
  name              = "${var.environment}-server-3"
  availability_zone = var.availability_zone3
  flavor_id         = var.flavor_id
  key_pair          = opentelekomcloud_compute_keypair_v2.rke2-server-key.name
  security_groups   = ["${var.environment}-secgroup"]
  user_data         = data.template_file.rke2_node.rendered
  power_state       = var.power_state
  network {
    uuid = opentelekomcloud_vpc_subnet_v1.subnet.id
  }
  block_device {
    boot_index            = 0
    source_type           = "image"
    destination_type      = "volume"
    uuid                  = data.opentelekomcloud_images_image_v2.image-2.id
    delete_on_termination = true
    volume_size           = 30
  }
}
