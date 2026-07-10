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

3. Initialize Terraform:
   - use the Azure Storage remote state backend:
     ```bash
     terraform init \
       -backend-config="resource_group_name=rg-azure-rhel-ansible-lab-tfstate" \
       -backend-config="storage_account_name=<your_tfstate_storage_account>" \
       -backend-config="container_name=tfstate" \
       -backend-config="key=azure-rhel-ansible-lab.tfstate" \
       -backend-config="access_key=<storage_account_access_key>"
     ```
   - or keep state local for one-off work:
     ```bash
     terraform init -backend=false
     ```

4. Deploy:
   ```bash
   terraform plan
   terraform apply
   ```

5. Get the VM public IP:
   ```bash
   terraform output vm_public_ip
   ```

6. Test SSH directly:
   ```bash
   ssh azureuser@<VM_PUBLIC_IP>
   ```

7. Use with Ansible inventory:
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

## GitHub Actions: Terraform + Ansible

This repo includes a workflow at `.github/workflows/terraform-ansible.yml` that:
- logs into Azure
- creates or reuses an Azure Storage account/container for Terraform remote state
- runs `terraform init/plan/apply`
- creates a dynamic Ansible inventory from Terraform outputs
- runs both playbooks:
   - `ansible/setup-golang-dotnet10.yml`
   - `ansible/update-rhel-playbook.yml`

### Remote state backend

GitHub Actions bootstraps a dedicated backend automatically before `terraform init`:
- resource group: `rg-<lowercase repo name>-tfstate` (for this repo: `rg-azure-rhel-ansible-lab-tfstate`)
- container: `tfstate`
- state key: `<lowercase repo name>.tfstate` (for this repo: `azure-rhel-ansible-lab.tfstate`)
- storage account name: `st<first 14 alphanumeric chars of the lowercase repo name><first 8 lowercase alphanumeric chars of AZURE_SUBSCRIPTION_ID after removing hyphens>` (for example: `st` + `azurerhelansib` + `1234abcd` = `stazurerhelansib1234abcd`)
- fallback: if a repo name ever sanitizes to an empty string, the workflow uses `repo<GITHUB_REPOSITORY_ID>` as the prefix source instead

No additional GitHub secret is required for the backend. The workflow reuses the existing Azure OIDC secrets to create the storage account, then retrieves the storage account access key during the run and passes it to `terraform init`.

### Setting your SSH public key secret

Terraform reads your SSH public key from the `TF_VAR_ssh_public_key` secret so the VM is provisioned with your laptop's key, enabling direct SSH access. The `TF_VAR_` prefix is required because Terraform automatically maps environment variables with that prefix to input variables.

Set it once with:

```bash
gh secret set TF_VAR_ssh_public_key --repo BearCreekNerd/azure-rhel-ansible-lab < ~/.ssh/id_ed25519.pub
```

If your key is RSA instead:

```bash
gh secret set TF_VAR_ssh_public_key --repo BearCreekNerd/azure-rhel-ansible-lab < ~/.ssh/id_rsa.pub
```

Required repository secrets:
- `AZURE_CLIENT_ID` (app registration / service principal application ID)
- `AZURE_TENANT_ID` (Microsoft Entra tenant ID)
- `AZURE_SUBSCRIPTION_ID` (Azure subscription ID)
- `SSH_PRIVATE_KEY` (private key matching the public key below)
- `TF_VAR_ssh_public_key` (public key content used by Terraform for VM provisioning)

OIDC setup (recommended, no long-lived Azure client secret):

1. Create an app registration and service principal:

   ```bash
   az ad app create --display-name "gha-azure-rhel-ansible-lab"
   APP_ID=$(az ad app list --display-name "gha-azure-rhel-ansible-lab" --query "[0].appId" -o tsv)
   az ad sp create --id "$APP_ID"
   ```

2. Grant RBAC to your scope (resource group preferred):

   ```bash
   SUBSCRIPTION_ID="<SUBSCRIPTION_ID>"
   RESOURCE_GROUP="<RESOURCE_GROUP_NAME>"
   az role assignment create \
     --assignee "$APP_ID" \
     --role Contributor \
     --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP"
   ```

3. Add a federated credential for this repo/branch:

   ```bash
   APP_OBJECT_ID=$(az ad app list --display-name "gha-azure-rhel-ansible-lab" --query "[0].id" -o tsv)
   cat > federated-credential.json <<'EOF'
   {
     "name": "github-main-branch",
     "issuer": "https://token.actions.githubusercontent.com",
     "subject": "repo:BearCreekNerd/azure-rhel-ansible-lab:ref:refs/heads/main",
     "description": "GitHub Actions access for main branch",
     "audiences": ["api://AzureADTokenExchange"]
   }
   EOF
   az ad app federated-credential create --id "$APP_OBJECT_ID" --parameters federated-credential.json
   ```

4. Save these repo secrets in GitHub:

   ```text
   AZURE_CLIENT_ID=<APP_ID>
   AZURE_TENANT_ID=<TENANT_ID>
   AZURE_SUBSCRIPTION_ID=<SUBSCRIPTION_ID>
   SSH_PRIVATE_KEY=<private key content>
   TF_VAR_ssh_public_key=<public key content>
   ```

Trigger options:
- manual: Actions -> Terraform + Ansible -> Run workflow
- automatic on push to `main` when Terraform, Ansible, or workflow files change
