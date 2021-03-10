#!/usr/bin/env bash
#
# usage: provision-aks.sh ws2 10.12.0.0 AAD-ADMIN-GROUP-OBJECT-ID

AKS_PREFIX=$1
VNET_ADDRESS_PREFIX=$2
ADMIN_GROUP_ID=$3
PREFIX="iac"

RESOURCE_GROUP_NAME="${PREFIX}-${AKS_PREFIX}-aks-rg"
AKS_NAME="aks-${AKS_PREFIX}"
VNET_NAME="${PREFIX}-${AKS_PREFIX}-aks-vnet"
MANAGED_IDENTITY_NAME="${PREFIX}-${AKS_PREFIX}-aks-mi"

# Create AKS resource group
echo -e "Create ${RESOURCE_GROUP_NAME} resource group"
az group create -g ${RESOURCE_GROUP_NAME} -l westeurope 

# Create AKS Vnet
echo -e "Create ${VNET_NAME} VNet"
az network vnet create -g ${RESOURCE_GROUP_NAME} -n ${VNET_NAME} --address-prefix "${VNET_ADDRESS_PREFIX}/16" --subnet-name aks-net --subnet-prefix "${VNET_ADDRESS_PREFIX}/20"

# Get subnet Id
SUBNET_ID="$(az network vnet subnet show -g ${RESOURCE_GROUP_NAME} --vnet-name ${VNET_NAME} -n aks-net --query id -o tsv)"

# Create user assigned managed identity
echo -e "Create User Assigned Managed Identity ${MANAGED_IDENTITY_NAME}"
az identity create --name ${MANAGED_IDENTITY_NAME} --resource-group ${RESOURCE_GROUP_NAME}

# Get managed identity ID
MANAGED_IDENTITY_ID="$(az identity show --name ${MANAGED_IDENTITY_NAME} --resource-group ${RESOURCE_GROUP_NAME} --query id -o tsv)"

# Create AKS cluster
echo -e "Create AKS cluster ${AKS_NAME}"
az aks create -g ${RESOURCE_GROUP_NAME} -n ${AKS_NAME} \
    --nodepool-name systempool  \
    --node-count 3 \
    --max-pods 110 \
    --enable-aad --aad-admin-group-object-ids ${ADMIN_GROUP_ID} \
    --kubernetes-version 1.19.6 \
    --network-plugin azure \
    --node-vm-size Standard_D2_v3 \
    --network-policy calico \
    --vm-set-type VirtualMachineScaleSets \
    --docker-bridge-address 172.17.0.1/16 \
	--enable-managed-identity \
    --assign-identity ${MANAGED_IDENTITY_ID} \
    --vnet-subnet-id ${SUBNET_ID} \
    --no-ssh-key 

