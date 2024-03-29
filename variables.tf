####################
# Environment
####################

variable "environment" {
  default = "k3s-test"
}

####################
#   OTC auth config
####################

variable "region" {
  default = "eu-de"
}

variable "otc_domain" {
  default = "eu-de"
}

variable "auth_url" {
  default = "https://iam.eu-de.otc.t-systems.com:443/v3"
}

variable "tenant_name" {
  default = "eu-de"
}

variable "access_key" {
  default = ""
}

variable "secret_key" {
  default = ""
}

variable "key" {
  default = ""
}

####################
# VPC vars
####################

variable "vpc_cidr" {
  description = "CIDR of the VPC"  
  default     = "10.1.0.0/24"
}

####################
# Subnet vars
####################

variable "subnet_cidr" {
  description = "CIDR of the Subnet"  
  default     = "10.1.0.0/24"
}

variable "subnet_gateway_ip" {
  description = "Default gateway of the Subnet"  
  default     = "10.1.0.1"
}

variable "subnet_primary_dns" {
  description = "Primary DNS server of the Subnet"  
  default     = "100.125.4.25"
}

variable "subnet_secondary_dns" {
  description = "Secondary DNS server of the Subnet"  
  default     = "100.125.129.199"
}

####################
# ELB vars
####################

variable "elb_whitelist" {
  description = "Enable Whitelisting for ELB Internet access"  
  default     = false
  type        = bool
}

variable "elb_whitelistips" {
  description = "Whitelist IPs for ELB Internet access"  
  default     = "80.158.48.20/32,80.158.48.21/32,80.158.48.29/32,80.158.48.30/32" # SNAP IP Pool
}

####################
# RDS vars
####################

variable "rds_root_password" {
  description = "RDS Root Password"  
  default     = ""
}

#variable "rds_lock" {
#  description = "Prevent RDS for destroying"
#  default     = false
#  type        = bool
#}

variable "rds_type" {
  description = "RDS Type"  
  default     = "MySQL"
}

variable "rds_version" {
  description = "Version of RDS"
  default     = "8.0"
}

variable "rds_port" {
  description = "Port of RDS"
  default     = "3306"
}

variable "rds_az" {
  description = "Availability zones of RDS (minimum 2)"
  default     = ["eu-de-01" , "eu-de-02"]
}

variable "rds_volume_type" {
  description = "Volume type of RDS (COMMON or ULTRAHIGH)"
  default     = "COMMON"
}

variable "rds_volume_size" {
  description = "Volume size of RDS in GB (40 minimum)"
  default     = "40"
}

variable "rds_flavor" {
  description = "Flavor of RDS"
  default     = "rds.mysql.c2.medium.ha"
}

variable "rds_ha_mode" {
  description = "Use HA RDS service"
  type        = string
  default     = "async" # or 'null' in non-ha
}

variable "rds_db" {
  description = "Name of the RDS schema"
  default     = "k3s"
}

####################
# ECS vars
####################

variable "availability_zone1" {
  description = "Availability Zone 1 (Biere)"
  default     = "eu-de-01"
}

variable "availability_zone2" {
  description = "Availability Zone 2 (Magdeburg)"
  default     = "eu-de-02"
}

variable "availability_zone3" {
  description = "Availability Zone 3 (Biere)"
  default     = "eu-de-03"
}

variable "image_name_server-1" {
  description = "Name of the image"
  default     = "Standard_Ubuntu_22.04_latest"
}

variable "image_name_server-2" {
  description = "Name of the image"
  default     = "Standard_Ubuntu_22.04_latest"
}

variable "flavor_id" {
  description = "ID of Flavor"
  default     = "c3.large.4"
}

variable "public_key" {
  description = "ssh public key to use"
  default     = ""
}

variable "power_state" {
  description = "Power state of ECS instances"
  default     = "active"
}

variable "deploy_wireguard" {
  description = "Deploy a Wireguard Server to access the internal network"
  default     = false
  type        = bool
} 

variable "wg_flavor_id" {
  description = "ID of Wireguard Flavor"
  default     = "c3.large.2"
}

variable "wg_server_address" {
  description = "Ip address of the Wireguard Server"
  default     = "10.2.0.1/24"
}

variable "wg_server_port" {
  description = "Port  of the Wireguard Server"
  default     = "51820"
}

variable "wg_server_private_key" {
  description = "Wireguard Server Private Key"
  default     = ""
}

variable "wg_server_public_key" {
  description = "Wireguard Server Public Key"
  default     = ""
}

variable "wg_peer_address" {
  description = "Wireguard Server Public Key"
  default     = "10.2.0.2/24"
}

variable "wg_peer_public_key" {
  description = "Wireguard Peer Public Key"
  default     = ""
}

####################
# DNS vars
####################

variable "create_dns" {
  description = "Create DNS entries"
  type        = bool
  default     = false
}

variable "rancher_host" {
  description = "Public host of the rancher instance"
  default     = "rancher"
}

variable "rancher_domain" {
  description = "Public domain of the rancher instance"
  default     = "example.com"
}

variable "admin_email" {
  description = "Admin email address for DNS and LetsEncrypt"
  default     = "nobody@example.com"
}

####################
# K3S/K8S vars
####################

variable "k3s_registry" {
  description = "replace docker.io registry with a customized endpoint for K3S installation"
  default     = ""
}

variable "k3s_version" {
  description = "K3S install version or channel, e.g stable/latest, v1.21.3+k3s1"
  default     = "stable"
}

variable "k3s_addon" {
  description = "Additional K3S start parameter" # e.g. --kube-apiserver-arg="enable-admission-plugins=NodeRestriction,PodSecurityPolicy,ServiceAccount"
  default     = ""
}

variable "token" {
  description = "Access Token for K3S Nodes (required since v1.20.9+k3s1"
  default     = ""
}

variable "cert-manager_version" {
  description = "Cert-Manager chart version"
  default     = "v1.8.1"
}

####################
# Rancher vars
####################

variable "registry" {
  description = "Registry for Rancher images"
  default = "mtr.devops.telekom.de"
}

variable "system-default-registry" {
  description = "System Registry for K3S"
  default = "mtr.devops.telekom.de"
}

variable "repo_certmanager" {
  description = "Repository of cert-manager Images"
  default = "quay.io/jetstack"
}

variable "image_traefik" {
  description = "Image for Traefik"
  default = "rancher/mirrored-library-traefik"
}

variable "rancher_version" {
  description = "Version of Rancher app"
  default     = "v2.7.0"
}

variable "rancher_tag" {
  description = "Tag of Rancher image"
  default     = "v2.7.0"
}

variable "admin_password" {
  description = "Bootstrap Password for Rancher 2.6"
  default     = "admin"
}
