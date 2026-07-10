param(
    [string]$ResourceGroup = "rg-ansible-safe-lab",
    [string]$VmName        = "rhel-ansible-safe-01",
    [string]$BastionName   = "bas-ansible-safe",
    [int]$LocalPort        = 50022
)

$ErrorActionPreference = "Stop"

$vmId = az vm show `
    --resource-group $ResourceGroup `
    --name $VmName `
    --query id `
    --output tsv

if (-not $vmId) {
    throw "Could not resolve VM ID for $VmName in resource group $ResourceGroup."
}

Write-Host "Starting Bastion tunnel on localhost:$LocalPort -> $VmName`:22"

az network bastion tunnel `
    --name $BastionName `
    --resource-group $ResourceGroup `
    --target-resource-id $vmId `
    --resource-port 22 `
    --port $LocalPort
