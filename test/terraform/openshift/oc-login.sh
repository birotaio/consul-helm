#!/usr/bin/env bash

set -e

resource_group=$1
cluster_name=$2

apiServer=$(az aro show -g "$resource_group" -n "$cluster_name" --query apiserverProfile.url -o tsv)
kubeUser=$(az aro list-credentials -g "$resource_group" -n "$cluster_name" | jq -r .kubeadminUsername)
kubePassword=$(az aro list-credentials -g "$resource_group" -n "$cluster_name" | jq -r .kubeadminPassword)

echo "Logging in"
for i in {1..20}; do oc login "$apiServer" -u "$kubeUser" -p "$kubePassword" && break; sleep 5; done
echo "Creating the 'consul' project"

echo "waiting for nodes to be ready"
kubectl wait --for=condition=ready --timeout=10m nodes --all

echo "waiting for nodes to be schedulable"
for i in {1..40}; do ! kubectl get nodes | grep SchedulingDisabled  && break; echo "some nodes have scheduling disabled; sleep 5"; sleep 5; done

# Idempotently, create and use the 'consul' project
set +e
oc new-project consul
oc project consul