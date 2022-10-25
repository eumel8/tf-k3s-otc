tf-k3s-otc
==========

[![Install Rancher on top of K3S on OTC with Terraform](https://i9.ytimg.com/vi_webp/hP2dJa64ArY/mqdefault.webp?time=1606254900000&sqp=CLSC9v0F&rs=AOn4CLCj9wWK0kcgBC5CHERXLyNXFjLjkA)](http://www.youtube.com/watch?v=hP2dJa64ArY "Install Rancher on top of K3S on OTC with Terraform")


Deploy [K3S](https://k3s.io) with Terraform on Open Telekom Cloud (OTC)
with the following resources:

* VPC
* Subnet
* Security Groups
* ELB
* RDS (minimal HA instance)
* ECS (2 master nodes Ubuntu 20.04)
* DNS (existing zone can be import with `terraform import opentelekomcloud_dns_zone_v2.dns <zone_id>`

Interested in [RKE2](https://docs.rke2.io)? Refer to the [rke2 branch](https://github.com/eumel8/tf-k3s-otc/tree/rke2) with
a full deployment of Kubernetes Cluster with RKE2 backend. This deployment has an etcd instead RDS as data backend.


Rancher:
--------

Rancher app will installed with LetsEncrypt cert under the configured hostname. 

You can reach the service under https://hostname.domain

Take a look on the [Support Matrix](https://www.suse.com/de-de/suse-rancher/support-matrix/all-supported-versions/rancher-v2-6-3/) 
which Rancher version fits for which K3S version and is supported.

Prerequistes:
------------

* Install Terraform CLI (v1.1.4+):

```
curl -o terraform.zip https://releases.hashicorp.com/terraform/1.1.4/terraform_1.1.4_linux_amd64.zip
unzip terraform
sudo mv terraform /usr/local/bin/
rm terraform.zip
```

* Switch to s3 folder and create a `terraform.tfvars` file for Terraform state S3 backend

```
bucket_name = <otc bucket name> # must be uniq
access_key  = <otc access key>
secret_key  = <otc secret key>
```

Deployment S3 backend:
----------------------

```
terraform init
terraform plan
terraform apply -auto-approve
```

* Create a `terraform.tfvars` file in the main folder

mandatory flags:

```
environment       = <environment name>    # e.g. "k3s-test"
rds_root_password = <rds_root_password>   # e.g. "12345678A+"
rancher_host      = <rancher host name>   # e.g. "k3s"
rancher_domain    = <rancher domain name> # e.g. "otc.mcsps.de"
rancher_version   = <rancher version>     # e.g. "v2.6.9"
rancher_tag       = <rancher image tag>   # e.g. "v2.6.9"
admin_email       = <admin email address for DNS/LetsEncrypt> # e.g. "nobody@telekom.de"
k3s_version       = <k3s version> # e.g. channel stable/latest or version "v1.23.8+k3s2"
access_key        = <otc access key>
secret_key        = <otc secret key>
public_key        = <public ssh key vor ECS>
```

additional features (optional):

```
create_dns              = <create dns zone/zonerecord in otc for rancher_host/rancher_dom> # e.g. "true"
elb_whitelist           = <enable ELB whitelist> # e.g. "true"
elb_whitelistips        = <list of elb whitelist ip-addresses> # e.g. "80.158.2.75/32"
flavor_id               = <bigger/other flavor for ECS instances> # e.g. "c3.xlarge.2"
k3s_registry            = <container registry "proxy" for docker.io (global) # e.g. "mtr.devops.telekom.de"
cert-manager_version    = <overwrite cert-manager chart version (depends on Rancher version, careful for Rancher issuer
registry                = <registry for Rancher images> # e.g. "mtr.devops.telekom.de"
system-default-registry = <system default registry for K3S> # e.g. "mtr.devops.telekom.de"
repo_certmanager        = <overwrite the repo for cert-manager> # e.g. "quay.io/jetstack"
image_traefik           = <overwrite the image for Traefik> # e.g. "rancher/mirrored-library-traefik"
k3s_addon               = <additional k3s start option> # e.g. "--kube-apiserver-arg=\"enable-admission-plugins=NodeRestriction,PodSecurityPolicy,ServiceAccount\""
```

* Adapt `bucket` name in `backend.tf` with the bucket name which you created before

(or delete file for local storage)

* Optional settings for other image/repo locations of different parts of the installation

```
variable "k3s_registry" {
  description = "replace docker.io registry with a customized endpoint for K3S installation"
  default     = ""
}

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
```

K3S supports [Airgap Installation](https://rancher.com/docs/k3s/latest/en/installation/airgap/),
where all images and the k3s binary can download from the release page and install locally on the
target node

Optain real client ip-addresses from ELB on Traefik logs:
---------------------------------------------------------

With TCP Option Address you can read the real client ip-address from ELB on Traefik logs. There is a
TOA Kernel Module to archive this. The original module from (Huawei)[https://github.com/Huawei/TCP_option_address]
is outdated. As a standard Kernel feature each (each other module)[https://github.com/ucloud/ucloud-toa] can
be used.

```
apt-get update
apt-get install -y git gcc make linux-headers-`uname -r`
git clone https://github.com/ucloud/ucloud-toa.git
cd ucloud-toa
make
insmod toa.ko 
lsmod |grep toa
toa                    16384  0
# dmesg |grep TOA
[40000.624129] TOA: TOA 2.0.0.0 by pukong.wjm
[40000.663859] TOA: CPU [1] sk_data_ready_fn = kallsyms_lookup_name(sock_def_readable) = 00000000f0ca8f39
[40000.663864] TOA: CPU [1] inet6_stream_ops_p = kallsyms_lookup_name(inet6_stream_ops) = 00000000487f49df
[40000.663864] TOA: CPU [1] ipv6_specific_p = kallsyms_lookup_name(ipv6_specific) = 00000000a382d798
[40000.663867] TOA: CPU [1] hooked inet_getname <00000000f51e2b2d> --> <0000000077c30c10>
[40000.663868] TOA: CPU [1] hooked tcp_v4_syn_recv_sock <00000000ceaf7e8b> --> <00000000bdfeea7b>
[40000.663869] TOA: CPU [1] hooked inet6_getname <00000000d483597c> --> <0000000026666108>
[40000.663870] TOA: CPU [1] hooked tcp_v6_syn_recv_sock <00000000720e8fc8> --> <00000000feb60d88>
[40000.663871] TOA: toa loaded
```

The running Kernel version must be the same as the module is compiled. Good practice is to download and
compile the module via cloud-init.

Verify traefik logs:

```
kubectl -n kube-system logs traefik-r2wvk
87.152.164.121 - - [05/Jul/2022:07:46:05 +0000] "GET /v1/events HTTP/2.0" 200 32619 "-" "-" 99 "websecure-rancher-cattle-system-k3s-otc-mcsps-de@kubernetes" "http://10.42.0.4:80" 55ms
```

Deployment main app:
--------------------

```
export S3_ACCESS_KEY=<otc access key>
export S3_SECRET_KEY=<otc secret key>
export TF_VAR_environment=<your k3s deployment> # e.g. k3s-test
export S3_BUCKET=<s3 bucket name> # e.g. tf-k3s-state
export S3_ENDPOINT=<s3 endpoint> # e.g. obs.eu-de.otc.t-systems.com
export S3_REGION=<s3 region> # e.g. eu-de

terraform init \
  -backend-config="access_key=$S3_ACCESS_KEY" \
  -backend-config="secret_key=$S3_SECRET_KEY" \
  -backend-config="key=${TF_VAR_environment}.tfstate" \
  -backend-config="bucket=$S3_BUCKET" \
  -backend-config="endpoint=$S3_ENDPOINT" \
  -backend-config="region=$S3_REGION"

terraform plan
terraform apply
```

Upgrades:
---------

It's possible to change the `k3s_version` variable and apply again with Terraform.
All VMs will be replaced because of the changed data content. Information are stored
in the database, so ground work should work out.

Better way is to use the [Rancher K3S Automatic Upgrade Procedure](https://rancher.com/docs/k3s/latest/en/upgrades/automated/)

```
kubectl apply -f https://github.com/rancher/system-upgrade-controller/releases/download/v0.8.1/system-upgrade-controller.yaml
```

There are 2 scripts to apply (adjust K3S Version first, based on the [Release Plan](https://github.com/rancher/k3s/releases)

```
kubectl apply -f k3s/k3s-upgrade-server.yaml
kubectl apply -f k3s/k3s-upgrade-agent.yaml
```

Rancher can upgrade manually:

```
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo update
helm -n cattle-system upgrade -i rancher rancher-latest/rancher
  --set hostname=rancher.example.com \
  --set ingress.tls.source=letsEncrypt \
  --set letsEncrypt.email=nobody@example.com \
  --set letsEncrypt.ingress.class=traefik \
  --set replicas=2 \
  --version v2.6.4
```

Notes: 

* Rancher upgrade via Rancher API will often fail due the Rancher pod restarts during upgrade
* Look into [support matrix](https://www.suse.com/suse-rancher/support-matrix/all-supported-versions)  which Rancher version supports which Kubernetes version


Cert-Manager as well:

```
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm -n cert-manager upgrade -i cert-manager jetstack/cert-manager \
    --version v1.8.1
```

Notes:

* For upgrade cert-manager from previous version (<1.7.0) use the migration tool before
`terraform apply` with newer version. Get (cmctl)[https://github.com/cert-manager/cert-manager/releases]

```
cmctl upgrade migrate-api-version
```

The stored Helm config needs also migrate:

```
# get latest release secret for Rancher
kubectl -n cattle-system get secret sh.helm.release.v1.rancher.v1 -o yaml > release.yaml
cat release.yaml | grep -oP '(?<=release: ).*' | base64 -d | base64 -d | gzip -d > release.data.decoded
sed -i -e 's/cert-manager.io\/v1beta1/cert-manager.io\/v1/' release.data.decoded 
cat release.data.decoded  | gzip | base64 | base64 > release.data.encoded 
tr -d "\n" < release.data.encoded > release.data.encoded.final
releaseData=$(cat release.data.encoded.final)
sed 's/^\(\s*release\s*:\s*\).*/\1'$releaseData'/' release.yaml > release-new.yaml
kubectl -n cattle-system apply -f release-new.yaml
```

compare: [Update Api Versions in Helm](https://helm.sh/docs/topics/kubernetes_apis/#updating-api-versions-of-a-release-manifest)

OS-Upgrade (i.e. Kernel/new image) can be done in the following way:

```
terraform taint opentelekomcloud_compute_instance_v2.k3s-server-1
terraform plan
```

This will replace k3s-server-1 with a new instance.

Note: this will also upgrade/downgrade the defined version of Rancher and Cert-Manager


Shutdown-Mode
-------------

Since Version 1.23.6 Terraform Open Telekom Cloud can handle ECS instance power state.

Shutoff:

```
terraform apply -auto-approve --var power_state=shutoff
```

Active:

```
terraform apply -auto-approve --var power_state=active
```

Retirement:
-----------

```
terraform destroy
```

Wireguard:
----------

In this deployment model there is no access with ssh to the nodes.
We can extend the deployment with a [Wireguard](https://www.wireguard.com) service
to create a vpn tunnel to access the internal network. There are multiple [clients](https://www.wireguard.com/install/)
(also for Windows).

At first it's required to install wireguard-tools and generate a keypair
for the Wireguard server:

```
sudo apt install -y wireguard-dkms wireguard-tools
wg genkey | tee privatekey | wg pubkey > publickey
```

Activate Wireguard deployment and put the content of the generated key
into terraform.tfvars:

```
deploy_wireguard      = "true"
wg_server_public_key  = "8EPWNuwv5vldRuLX4RNds/U78a8g2kTctNHRBClHTC4="
wg_server_private_key = "cNyppGTX8gwWLTRxxrNYfiRqTEjJSCMlBT+TbcEGAl8="
wg_peer_public_key    = "9tjOb+VA7vCHQj2rcOBSln8U7tVXzeEoBITYVuq1LFw="
```

Repeat key generating with the commands above or with the Wireguard client.
Add the public key into terraform.tfvars:

```
wg_peer_public_key    = "9tjOb+VA7vCHQj2rcOBSln8U7tVXzeEoBITYVuq1LFw="
```

Deploy with `terraform plan` & `terraform apply`

Client configuration example:

```
[Interface]
PrivateKey = 0ITNzekaBeanMGefS7iyS2hsgzGK50GOpF6NKHoPPwF8=
ListenPort = 51820
Address = 10.2.0.2/24

[Peer]
PublicKey = 3dgEPWNuwv5vldRuLX4RNdshsg78a8g2kTctNHRBClHTC4=
AllowedIPs = 10.2.0.1/32, 10.1.0.0/24, 80.158.6.126/32
Endpoint = 80.158.6.126:51820
```

* 10.2.0.1: Wireguard Server IP
* 10.2.0.2: Wireguard Client IP
* 10.1.0.0: Internal K3S Network
* 80.158.6.128: Floating IP of Wireguard Server

Windows user needs a manual route:

```
route add 10.1.0.0/24 mask 255.255.255.0 10.2.0.1
```

Debug:
------

Installation take a while (10-15 min). If no service is reachable you can check
console log to see cloud-init output. For that we have a [small programm](https://github.com/eumel8/otc-ecs-client/releases) to get easy console output, e.g. the first server:

```shell
./ecs -vm k3s-test-server-1                     
...
[  210.731060] cloud-init[1956]: Cloud-init v. 21.4-0ubuntu1~20.04.1 finished at Thu, 24 Mar 2022 14:07:45 +0000. Datasource DataSourceOpenStackLocal [net,ver=2].  Up 210.72 seconds
[[0;32m  OK  [0m] Finished [0;1;39mExecute cloud user/final scripts[0m.
[[0;32m  OK  [0m] Reached target [0;1;39mCloud-init target[0m.
```

you need OTC credentials, provided as environment variables to get the programm running


If this doesn't help you can login to the first ECS instance via Wireguard VPN.

```
ssh ubuntu@10.1.0.158
$ sudo su -
```

Check k3s is running:

```
root@k3s-server-1:~# systemctl status k3s.service
● k3s.service - Lightweight Kubernetes
     Loaded: loaded (/etc/systemd/system/k3s.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2020-09-18 14:48:42 UTC; 11min ago
```

Check Kubernetes is working:

```
root@k3s-server-1:~# kubectl get nodes
NAME           STATUS   ROLES    AGE     VERSION
k3s-server-1   Ready    master   37m     v1.18.8+k3s1
k3s-server-2   Ready    master   6m51s   v1.18.8+k3s1

root@k3s-server-1:~# kubectl get pods -A
NAMESPACE       NAME                                       READY   STATUS      RESTARTS   AGE
cert-manager    cert-manager-f845b6ffb-77p8c               1/1     Running     0          37m
cert-manager    cert-manager-cainjector-869786ffd7-6l4jq   1/1     Running     0          37m
kube-system     metrics-server-7566d596c8-wxhxb            1/1     Running     0          37m
kube-system     local-path-provisioner-6d59f47c7-d7l49     1/1     Running     0          37m
cert-manager    cert-manager-webhook-6b7c855d9d-b55z8      1/1     Running     0          37m
kube-system     helm-install-traefik-4jxdv                 0/1     Completed   1          37m
kube-system     coredns-7944c66d8d-2jmng                   1/1     Running     0          37m
kube-system     svclb-traefik-v4sf2                        2/2     Running     0          36m
kube-system     traefik-758cd5fc85-7cwmw                   1/1     Running     0          36m
cattle-system   rancher-5984bdd954-5dg6f                   1/1     Running     0          36m
cattle-system   rancher-5984bdd954-v9lqc                   1/1     Running     1          36m
cattle-system   rancher-5984bdd954-28vjz                   1/1     Running     0          36m
cattle-system   cattle-cluster-agent-b9656945d-6kxqc       1/1     Running     0          30m
cattle-system   cattle-node-agent-9hsnr                    1/1     Running     0          30m
cattle-system   cattle-node-agent-f4nc5                    1/1     Running     0          7m6s
kube-system     svclb-traefik-rfwgh                        2/2     Running     0          6m56s
```

Migration from RKE Cluster
--------------------------

The procedure is described in [Rancher docs](https://rancher.com/docs/rancher/v2.x/en/backups/v2.5/migrating-rancher/)

note: as mentioned Rancher version 2.5+ is needed.

working steps:

   * Upgrade Rancher 2.5+
   * Install [rancher-backup](https://rancher.com/docs/rancher/v2.x/en/backups/v2.5/#installing-rancher-backup-with-the-helm-cli)
   * Perform etcd backup
   * Perform S3 backup
   * Create Git Repo for new Raseed environment in a CI/CD pipeline
   * Shutdown old public endpoint (cluster agents of downstream cluster should disconnect)
   * Switch DNS entry of public endpoint (if no automation like external-dns is used)
   * Execute created CI/CD Pipeline for environment
   * Login into RancherUI of the new environment
   * Install rancher-backup
   * Restore S3 backup
   * Review downstream clusters


Credits:
-------

Frank Kloeker <f.kloeker@telekom.de>

Life is for sharing. If you have an issue with the code or want to improve it,
feel free to open an issue or an pull request.
