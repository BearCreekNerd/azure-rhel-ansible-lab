# Azure RHEL + Bastion Starter (for Ansible)

## What this creates
- Resource Group
- VNet + subnets:
  - `workload-subnet`
  - `AzureBastionSubnet`
- NSG allowing SSH from VirtualNetwork only
- Bastion host + Public IP
- RHEL 9 VM (private IP only, no public IP)

## Prereqs
- Terraform >= 1.6
- Azure CLI (`az`)
- SSH keypair on your machine

## Quickstart

1. Login:
   ```bash
   az login
   az account set --subscription "<SUBSCRIPTION_ID_OR_NAME>"
   ```

2. Copy vars:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # edit terraform.tfvars
   ```

3. Deploy:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. Start Bastion tunnel (PowerShell):
   ```powershell
   .\scripts\start-bastion-tunnel.ps1
   ```
   Keep it running in a terminal.

5. Test SSH:
   ```bash
   ssh -p 50022 azureuser@127.0.0.1
   ```

6. Use with Ansible inventory:
   ```ini
   [rhel]
   rhel-safe ansible_host=127.0.0.1 ansible_port=50022 ansible_user=azureuser ansible_ssh_private_key_file=~/.ssh/id_ed25519
   ```

## Destroy
```bash
terraform destroy
```
