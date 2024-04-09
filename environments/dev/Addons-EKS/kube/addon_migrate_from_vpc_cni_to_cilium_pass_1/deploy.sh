#!/usr/bin/env bash
cd "$(dirname "$0")"
set -eu

# Import unit testing library
source "../lib/assert.sh"

NAME=CNIMIGRATIONPHASE1

EKS_CLUSTER_NAME=$1
ADDON_ENABLED=$2

: "${EKS_CLUSTER_NAME?"Need to set EKS_CLUSTER_NAME"}"
: "${ADDON_ENABLED?"Need to set ADDON_ENABLED"}"


# DEFINE INSTALL FUNCTION
install_eks_addon() {

  local out
  log_header "Install Starting:: ${NAME}"

  # Label existing EKS nodes in order to constrain
  # the aws-node Daemonset only runs of these nodes
  for NODE in $(kubectl get node --output=jsonpath='{.items[*].metadata.name}'); do

      LABELED=$(kubectl get node $NODE -o json | jq '.metadata.labels | has("cni-plugin")')
      if [ "$LABELED" = "true" ]; then
            LABEL_VALUE=$(kubectl get node $NODE -o json | jq -r '.metadata.labels | .["cni-plugin"]')
            echo "Node $NODE already labeled: cni-plugin=$LABEL_VALUE"
      else
            kubectl label nodes $NODE cni-plugin=aws
      fi
  done

  # Verify all nodes labeled correctly
  LABELED_NODE_COUNT=$(kubectl get node -l cni-plugin=aws -o json | jq '.items | length')
  ALL_NODE_COUNT=$(kubectl get node -o json | jq '.items | length')

  if [ ! "$LABELED_NODE_COUNT" = "$ALL_NODE_COUNT" ]; then
      echo "NOT ALL NODES LABELED"
      echo "Labeled Nodes: $LABELED_NODE_COUNT, Total Nodes: $ALL_NODE_COUNT"
      exit 1
  fi

  echo "ALL NODES ARE LABELED"

  # Patch aws-node Daemonset
  kubectl patch daemonset aws-node -n kube-system --patch-file aws-node-patch.yaml

  echo "AWS-NODE DAEMONSET PATCHED"

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