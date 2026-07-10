#!/usr/bin/env bash
set -euo pipefail

RG="${RG:-rg-ansible-safe-lab}"
VM="${VM:-rhel-ansible-safe-01}"
BASTION="${BASTION:-bas-ansible-safe}"
LOCAL_PORT="${LOCAL_PORT:-50022}"

VM_ID="$(az vm show -g "$RG" -n "$VM" --query id -o tsv)"

echo "Starting Bastion tunnel on localhost:${LOCAL_PORT} -> ${VM}:22"
az network bastion tunnel \
  --name "$BASTION" \
  --resource-group "$RG" \
  --target-resource-id "$VM_ID" \
  --resource-port 22 \
  --port "$LOCAL_PORT"
