# GCP: Terraform to launch VM Cluster inside VPC

---------
## `Commands:`

```bash
git clone https://github.com/jpolara2016/Terraform-GCP-Compute-Cluster.git
cd terraform_ecs
terraform init
terraform validate
terraform plan
terraform apply
```
  
---------  
## `Resources:`

* VPC Network
    * High-availability (Multi-AZ deployment)
      * Public Subnet (Internet access via IG)
      * Private Subnet (Internet access via NAT Gateway)
    * Hily Available NAT Gateway for each private subnet
* Security
    * Firewall for Instances in Public Subnet
    * Firewall for Instances in Private Subnet (Access from only Public Subnet)
    * Firewall for SSH through IAP Tunnel
* Compute VM instance
    * In Private & Public Subnet
  
  
---------
## `Graph:`
```bash
terraform graph | dot -Tsvg > graph.svg
```
You can open graph.svg in any browser.
