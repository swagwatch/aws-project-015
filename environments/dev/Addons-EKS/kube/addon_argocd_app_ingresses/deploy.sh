#!/usr/bin/env bash
cd "$(dirname "$0")"
set -eu

# Import unit testing library
source "../lib/assert.sh"

NAME=INGRESSES

EKS_CLUSTER_NAME=$1
ADDON_ENABLED=$2

: "${EKS_CLUSTER_NAME?"Need to set EKS_CLUSTER_NAME"}"
: "${ADDON_ENABLED?"Need to set ADDON_ENABLED"}"


# DEFINE INSTALL FUNCTION
install_eks_addon() {

  local out
  log_header "Install Starting:: ${NAME}"

  # Get Kubeconfig
  aws eks update-kubeconfig --name=${EKS_CLUSTER_NAME}

  # Install Argo-CD Ingress
  kubectl apply -f argo-cd-ingress.yaml

  # Allow Route53 time to create A records before creating next ingress
  rand_sleep=$(( 60 ))
  echo "Sleeping ${rand_sleep} seconds"
  sleep ${rand_sleep}

  # Install Argo Workflows Ingress
  kubectl apply -f argo-workflow-ingress.yaml

  # Allow Route53 time to create A records before creating next ingress
  rand_sleep=$(( 60 ))
  echo "Sleeping ${rand_sleep} seconds"
  sleep ${rand_sleep}

  # Install Grafana Ingress
  kubectl apply -f grafana-ingress.yaml

  # Allow Route53 time to create A records before creating next ingress
  rand_sleep=$(( 60 ))
  echo "Sleeping ${rand_sleep} seconds"
  sleep ${rand_sleep}

  # Install Opencost Ingress
  kubectl apply -f opencost-ingress.yaml

  # Allow Route53 time to create A records before creating next ingress
  rand_sleep=$(( 60 ))
  echo "Sleeping ${rand_sleep} seconds"
  sleep ${rand_sleep}

  # Install Jupyterhub Ingress
  kubectl apply -f jupyterhub-ingress.yaml

  # LOG TO CONSOLE
  log_header "Install Complete :: ${NAME} ::"

}


###main###
if [[ "${ADDON_ENABLED}" == "true" ]]
then
  install_eks_addon
elif [[ "${ADDON_ENABLED}" == "false"  ]]
then
  echo "ADDON DISABLED"
fi