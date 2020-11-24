tf-k3s-otc
==========

Scalr-Branch: install infrastructure beside ECS
-----------------------------------------------

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

Credits:
-------

Frank Kloeker <f.kloeker@telekom.>

Life is for sharing. If you have an issue with the code or want to improve it,
feel free to open an issue or an pull request.
