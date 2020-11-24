
########### 
# VPC part
########### 
resource "opentelekomcloud_vpc_v1" "vpc" {
  name   = var.environment
  cidr   = var.vpc_cidr
  shared = true
}

resource "opentelekomcloud_vpc_subnet_v1" "subnet" {
  name       = var.environment
  vpc_id     = opentelekomcloud_vpc_v1.vpc.id
  cidr       = var.subnet_cidr
  gateway_ip = var.subnet_gateway_ip
  dns_list   = [ "100.125.4.25", "100.125.129.199" ]
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
 
resource "opentelekomcloud_lb_monitor_v2" "monitor_80" {
  pool_id     = opentelekomcloud_lb_pool_v2.pool_80.id
  type        = "TCP"
  delay       = 20
  timeout     = 10
  max_retries = 5
}

resource "opentelekomcloud_lb_monitor_v2" "monitor_443" {
  pool_id     = opentelekomcloud_lb_pool_v2.pool_443.id
  type        = "TCP"
  delay       = 20
  timeout     = 10
  max_retries = 5
}
 
resource "opentelekomcloud_lb_monitor_v2" "monitor_6443" {
  pool_id     = opentelekomcloud_lb_pool_v2.pool_6443.id
  type        = "TCP"
  delay       = 20
  timeout     = 10
  max_retries = 5
}

# server 1
resource "opentelekomcloud_lb_member_v2" "member_80_1" {
  address       = opentelekomcloud_compute_instance_v2.k3s-server-1.access_ip_v4
  protocol_port = 80
  pool_id       = opentelekomcloud_lb_pool_v2.pool_80.id
  subnet_id     = opentelekomcloud_vpc_subnet_v1.subnet.subnet_id
}

resource "opentelekomcloud_lb_member_v2" "member_443_1" {
  address       = opentelekomcloud_compute_instance_v2.k3s-server-1.access_ip_v4
  protocol_port = 443
  pool_id       = opentelekomcloud_lb_pool_v2.pool_443.id
  subnet_id     = opentelekomcloud_vpc_subnet_v1.subnet.subnet_id
}

resource "opentelekomcloud_lb_member_v2" "member_6443_1" {
  address       = opentelekomcloud_compute_instance_v2.k3s-server-1.access_ip_v4
  protocol_port = 6443
  pool_id       = opentelekomcloud_lb_pool_v2.pool_6443.id
  subnet_id     = opentelekomcloud_vpc_subnet_v1.subnet.subnet_id
}
 
# server 2
resource "opentelekomcloud_lb_member_v2" "member_80_2" {
  address       = opentelekomcloud_compute_instance_v2.k3s-server-2.access_ip_v4
  protocol_port = 80
  pool_id       = opentelekomcloud_lb_pool_v2.pool_80.id
  subnet_id     = opentelekomcloud_vpc_subnet_v1.subnet.subnet_id
}

resource "opentelekomcloud_lb_member_v2" "member_443_2" {
  address       = opentelekomcloud_compute_instance_v2.k3s-server-2.access_ip_v4
  protocol_port = 443
  pool_id       = opentelekomcloud_lb_pool_v2.pool_443.id
  subnet_id     = opentelekomcloud_vpc_subnet_v1.subnet.subnet_id
}

resource "opentelekomcloud_lb_member_v2" "member_6443_2" {
  address       = opentelekomcloud_compute_instance_v2.k3s-server-2.access_ip_v4
  protocol_port = 6443
  pool_id       = opentelekomcloud_lb_pool_v2.pool_6443.id
  subnet_id     = opentelekomcloud_vpc_subnet_v1.subnet.subnet_id
}

########### 
# RDS part
########### 
resource "opentelekomcloud_networking_secgroup_v2" "secgroup" {
  name        = "${var.environment}-rds-secgroup"
  description = "terraform security group rds"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "secgroup_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.rds_port
  port_range_max    = var.rds_port
  remote_ip_prefix  = var.subnet_cidr
  security_group_id = opentelekomcloud_networking_secgroup_v2.secgroup.id
}

resource "opentelekomcloud_rds_parametergroup_v3" "pg" {
    name        = "${var.environment}-rds-pg"
    description = "Parameter Group for ${var.environment}-rds RDS"
    values = {
        local_infile                         = "OFF"
        max_user_connections                 = "1000"
        validate_password_length             = "10"
        validate_password_number_count       = "1"
        validate_password_special_char_count = "1"
    }
    datastore {
        type    = "mysql"
        version = var.rds_version
    }
}

resource "opentelekomcloud_rds_instance_v3" "rds" {
  availability_zone = var.rds_az
  db {
    password = var.rds_root_password
    type     = var.rds_type
    version  = var.rds_version
    port     = var.rds_port
  }
  name              = "${var.environment}-rds"
  security_group_id = opentelekomcloud_networking_secgroup_v2.secgroup.id
  subnet_id         = opentelekomcloud_vpc_subnet_v1.subnet.id
  vpc_id            = opentelekomcloud_vpc_v1.vpc.id
  volume {
    type = var.rds_volume_type
    size = var.rds_volume_size
  }
  ha_replication_mode = var.rds_ha_mode
  param_group_id      = opentelekomcloud_rds_parametergroup_v3.pg.id
  flavor              = var.rds_flavor
  backup_strategy {
    start_time = "08:00-09:00"
    keep_days  = 30
  }
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

data "template_file" "k3s_server" {
  template = file("${path.module}/files/k3s_server")
  vars = {
    rds_root_password = var.rds_root_password
    rds_db            = var.rds_db
    rds_port          = var.rds_port
    rds_host          = opentelekomcloud_rds_instance_v3.rds.private_ips.0
    admin_email       = var.admin_email
    rancher_host      = var.rancher_host
    rancher_domain    = var.rancher_domain
  }
}

data "template_file" "k3s_node" {
  template = file("${path.module}/files/k3s_node")
  vars = {
    rds_root_password = var.rds_root_password
    rds_db            = var.rds_db
    rds_port          = var.rds_port
    rds_host          = opentelekomcloud_rds_instance_v3.rds.private_ips.0
  }
}

data "opentelekomcloud_images_image_v2" "image" {
  name        = var.image_name
  most_recent = true
}
 
# Secgroup part (ECS)
resource "opentelekomcloud_networking_secgroup_v2" "k3s-server-secgroup" {
  name = "${var.environment}-secgroup"
}
 
resource "opentelekomcloud_networking_secgroup_rule_v2" "sg_k3s_all_out" {
  direction         = "egress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = opentelekomcloud_networking_secgroup_v2.k3s-server-secgroup.id
}
 
resource "opentelekomcloud_networking_secgroup_rule_v2" "sg_k3s_22_in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = opentelekomcloud_networking_secgroup_v2.k3s-server-secgroup.id
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "sg_k3s_80_in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = opentelekomcloud_networking_secgroup_v2.k3s-server-secgroup.id
}
 
resource "opentelekomcloud_networking_secgroup_rule_v2" "sg_k3s_443_in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = opentelekomcloud_networking_secgroup_v2.k3s-server-secgroup.id
}
 
resource "opentelekomcloud_networking_secgroup_rule_v2" "sg_k3s_6443_in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = opentelekomcloud_networking_secgroup_v2.k3s-server-secgroup.id
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "sg_k3s_8472_in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 8472
  port_range_max    = 8472
  remote_ip_prefix  = "0.0.0.0/0"
 security_group_id = opentelekomcloud_networking_secgroup_v2.k3s-server-secgroup.id
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "sg_k3s_10250_in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10250
  port_range_max    = 10250
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = opentelekomcloud_networking_secgroup_v2.k3s-server-secgroup.id
}

# ssh key part
resource "opentelekomcloud_compute_keypair_v2" "k3s-server-key" {
  name       = "{$var.environment}-key"
  public_key = var.public_key
}

# ECS part (instances)
resource "opentelekomcloud_compute_instance_v2" "k3s-server-1" {
  name              = "${var.environment}-server-1"
  availability_zone = var.availability_zone1
  flavor_id         = var.flavor_id
  key_pair          = opentelekomcloud_compute_keypair_v2.k3s-server-key.name
  security_groups   = [opentelekomcloud_networking_secgroup_v2.k3s-server-secgroup.id]
  user_data         = data.template_file.k3s_server.rendered
  network {
    uuid = opentelekomcloud_vpc_subnet_v1.subnet.id
  }
  block_device {
    boot_index            = 0
    source_type           = "image"
    destination_type      = "volume"
    uuid                  = data.opentelekomcloud_images_image_v2.image.id
    delete_on_termination = true
    volume_size           = 30
  }
}

resource "opentelekomcloud_compute_instance_v2" "k3s-server-2" {
  name              = "${var.environment}-server-2"
  availability_zone = var.availability_zone2
  flavor_id         = var.flavor_id
  key_pair          = opentelekomcloud_compute_keypair_v2.k3s-server-key.name
  security_groups   = [opentelekomcloud_networking_secgroup_v2.k3s-server-secgroup.id]
  user_data         = data.template_file.k3s_node.rendered
  network {
    uuid = opentelekomcloud_vpc_subnet_v1.subnet.id
  }
  block_device {
    boot_index            = 0
    source_type           = "image"
    destination_type      = "volume"
    uuid                  = data.opentelekomcloud_images_image_v2.image.id
    delete_on_termination = true
    volume_size           = 30
  }
}
 
# MySQL part (needs to be run in VPC)
# #provider "mysql" {
# #   endpoint = "${var.rds_host}:${var.rds_port}"
# #   username = "root"
# #   password = var.rds_root_password
# #}
# #
# #resource "mysql_database" "app_db" {
# #  name = var.rds_app_user
# #}
# #
# #resource "mysql_user" "app_user" {
# #  user               = var.rds_app_user
# #  host               = "%"
# #  plaintext_password = var.rds_app_password
# #}
# #
# #resource "mysql_grant" "app_user" {
# #  user       = var.rds_app_user
# #  host       = "%"
# #  database   = var.rds_app_user
# #  privileges = ["ALL PRIVILEGES"]
# #}
