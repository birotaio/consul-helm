#!/usr/bin/env sh

set -e

resource_group=$1
cluster_name=$2

apiServer=$(az aro show -g "$resource_group" -n "$cluster_name" --query apiserverProfile.url -o tsv)
kubeUser=$(az aro list-credentials -g "$resource_group" -n "$cluster_name" | jq -r .kubeadminUsername)
kubePassword=$(az aro list-credentials -g "$resource_group" -n "$cluster_name" | jq -r .kubeadminPassword)

echo "Logging in"
for i in {1..5}; do oc login "$apiServer" -u "$kubeUser" -p "$kubePassword" && break; sleep 2; done
echo "Creating the 'consul' project"
oc new-project consul