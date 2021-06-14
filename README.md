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

Prerequistes:
------------

* Install Terraform CLI (v0.13.2+):

```
curl -o terraform.zip https://releases.hashicorp.com/terraform/0.13.2/terraform_0.13.2_linux_amd64.zip
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

```
environment       = <environment name>    # e.g. "k3s-test"
rds_root_password = <rds_root_password>   # e.g. "12345678A+"
rancher_host      = <rancher host name>   # e.g. "k3s"
rancher_domain    = <rancher domain name> # e.g. "otc.mcsps.de"
admin_email       = <admin email address for DNS/LetsEncrypt> # e.g. "nobody@telekom.de"
k3s_version       = <k3s version> # e.g. channel stable/latest or version v1.17.13+k3s2
access_key        = <otc access key>
secret_key        = <otc secret key>
public_key        = <public ssh key vor ECS>
```

* Adapt `bucket` name in `backend.tf` with the bucket name which you created before

Deployment main app:
--------------------

```
export S3_ACCESS_KEY=<otc access key>
export S3_SECRET_KEY=<otc secret key>
export TF_VAR_environment=<your k3s deployment>

terraform init -backend-config="access_key=$S3_ACCESS_KEY" -backend-config="secret_key=$S3_SECRET_KEY" -backend-config="key=${TF_VAR_environment}.tfstate"

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
kubectl apply -f https://github.com/rancher/system-upgrade-controller/releases/download/v0.6.2/system-upgrade-controller.yaml
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
  --version v2.5.6 
```

Note: Rancher upgrade via Rancher API will often fail due the Rancher pod restarts during upgrade

Cert-Manager as well:

```
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm -n cert-manager upgrade -i cert-manager jetstack/cert-manager \
    --version v1.2.0
```

OS-Upgrade (i.e. Kernel/new image) can be done in the following way:

```
terraform taint opentelekomcloud_compute_instance_v2.k3s-server-1
terraform plan
```

This will replace k3s-server-1 with a new instance.

Note: this will also upgrade/downgrad the defined version of Rancher and Cert-Manager


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

Debug:
------

Installation take a while (10-15 min). If no service is reachable you can login
to the first ECS instance. Most of the things should happen there in cloud-init:

```
openstack floating ip create admin_external_net
openstack server add floating ip  k3s-server-1 80.158.1.100
ssh ubuntu@80.158.1.100
$ sudo su -
# tail /var/log/cloud-init-output.log
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
