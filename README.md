# flux-poc
Experimenting with flux at AKS

## Install

```bash
# Find your AAD group object id
ADMIN_GROUP_ID="$(az ad group show -g YOUR-AAD-GROUP-NAME --query objectId -o tsv)"

# Provision new AKS cluster
./scripts/provision-aks.sh flux-poc 10.14.0.0 ${ADMIN_GROUP_ID}

# Get AKS credentials (if you use different PREFIX inside provision-aks.sh, replace iac- with your prefix)
az aks get-credentials -g iac-flux-poc-aks-rg -n aks-flux-poc

# Add flux repo 
helm repo add fluxcd https://charts.fluxcd.io

# Create flux ns
kubectl create ns flux

# deploy flux 
helm upgrade -i flux fluxcd/flux --set git.url=git@ssh.dev.azure.com:v3/AZURE-DEVOPS-ORG/PROJECT/REPO --set git.branch=main --set git.path=manifests --set registry.disableScanning=true --set prometheus.serviceMonitor.create=true --set dashboards.enabled=true --set prometheus.enabled=true --namespace flux

# flux rollout deployment
kubectl -n flux rollout status deployment/flux

# Get SSH key  (linux)
kubectl -n flux logs deployment/flux | grep identity.pub | cut -d '"' -f2

# Get SSH key  (powershell)
kubectl -n flux logs deployment/flux | grep identity.pub 

# Add SSH key to your `SSH public keys` https://dev.azure.com/AZURE-DEVOPS-ORG/_usersSettings/keys

# 
```
