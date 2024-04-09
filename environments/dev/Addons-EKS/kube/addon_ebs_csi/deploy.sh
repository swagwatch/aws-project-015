#!/usr/bin/env bash
cd "$(dirname "$0")"
set -eu

# Import unit testing library
source "../lib/assert.sh"

NAME=ebscsidriver

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

  # Create EBS Storage Classses
  kubectl apply -f ebs-csi-storageclass-ebs-sc.yaml

  kubectl apply -f ebs-csi-storageclass-gp3.yaml

  # Remove (default) setting from gp2 storage class
  kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

  # Set ebs-sc as the default storage class
  kubectl patch storageclass ebs-sc -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}' 

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