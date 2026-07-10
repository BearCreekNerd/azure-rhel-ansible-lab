# Azure RHEL VM Starter (for Ansible)

## What this creates
- Resource Group
- VNet + workload subnet
- NSG allowing SSH from your configured source CIDR
- RHEL 9 VM with a public IP

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

4. Get the VM public IP:
   ```bash
   terraform output vm_public_ip
   ```

5. Test SSH directly:
   ```bash
   ssh azureuser@<VM_PUBLIC_IP>
   ```

6. Use with Ansible inventory:
   ```ini
   [rhel]
   rhel-safe ansible_host=<VM_PUBLIC_IP> ansible_user=azureuser ansible_ssh_private_key_file=~/.ssh/id_ed25519
   ```

## Ansible: Install Go + .NET 10

Run the included playbook from WSL, Linux, or another Unix-like shell. Native Windows PowerShell with the Windows Python build can fail with `WinError 1` before Ansible starts.

```bash
cd ansible
ansible-playbook -i inventory.ini setup-golang-dotnet10.yml
```

If you prefer to stay at the repo root, use:

```bash
ansible-playbook -i ansible/inventory.ini ansible/setup-golang-dotnet10.yml
```

If you see `Host key verification failed`, your VM host key in `~/.ssh/known_hosts` is missing or stale (common after VM re-create). Fix it with:

```bash
ssh-keygen -R <VM_PUBLIC_IP>
ssh-keyscan -H <VM_PUBLIC_IP> >> ~/.ssh/known_hosts
ssh azureuser@<VM_PUBLIC_IP>
```

Then validate Ansible connectivity before running the full playbook:

```bash
ansible -i ansible/inventory.ini all -m ping
```

If you see `Failed to validate GPG signature ... Public key for packages-microsoft-prod.rpm is not installed`, pull the latest playbook and rerun. The playbook imports Microsoft's RPM signing key before installing the repo package.

## Destroy
```bash
terraform destroy
```
