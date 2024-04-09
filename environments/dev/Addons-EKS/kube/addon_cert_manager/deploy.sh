#!/usr/bin/env bash
cd "$(dirname "$0")"
set -eu

# Import unit testing library
source "../lib/assert.sh"

NAME=certmanager

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

  # Create Cert Manager Cluster Issuer
  kubectl apply -f cluster_issuer.yaml

  # Create Cert Manager Cluster Wildcard Certificate
  kubectl apply -f certificate.yaml

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