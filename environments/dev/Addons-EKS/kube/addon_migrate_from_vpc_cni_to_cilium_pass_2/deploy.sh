#!/usr/bin/env bash
cd "$(dirname "$0")"
set -eu

# Import unit testing library
source "../lib/assert.sh"

NAME=CNIMIGRATIONPHASE2

EKS_CLUSTER_NAME=$1
ADDON_ENABLED=$2

: "${EKS_CLUSTER_NAME?"Need to set EKS_CLUSTER_NAME"}"
: "${ADDON_ENABLED?"Need to set ADDON_ENABLED"}"


# DEFINE INSTALL FUNCTION
install_eks_addon() {

  local out
  log_header "Install Starting:: ${NAME}"

  # Remove all nodes with label cni-plugin=aws
  for NODE in $(kubectl get node --output=jsonpath='{.items[*].metadata.name}'); do

      LABELED=$(kubectl get node $NODE -o json | jq '.metadata.labels | has("cni-plugin")')
      if [ "$LABELED" = "true" ]; then

            LABEL_VALUE=$(kubectl get node $NODE -o json | jq -r '.metadata.labels | .["cni-plugin"]')
            echo "Removing Node $NODE with label: cni-plugin=$LABEL_VALUE"

            # Cordon Node
            echo "Cordoning Node: ${NODE}"
            kubectl cordon ${NODE}

            # Drain Node
            echo "Draining Node: ${NODE}"
            kubectl drain ${NODE} --delete-emptydir-data --ignore-daemonsets --force

            # Delete Node
            echo "Deleting Node: ${NODE}"
            kubectl delete node ${NODE}

            # Get Node Instance ID
            echo "Getting Instance ID for Node: ${NODE}"
            NODEID=$(aws ec2 --region=us-east-1 describe-instances --filter Name=private-dns-name,Values=${NODE} --no-cli-pager |jq -r ".Reservations[0].Instances[0].InstanceId")

            # Remove Node From Autoscaling Group
            echo "Removing Node ${NODE} From Autoscaling Group at Instance ID: ${NODEID}"
            aws autoscaling --region=us-east-1 terminate-instance-in-auto-scaling-group --instance-id ${NODEID} --no-should-decrement-desired-capacity --no-cli-pager

            echo "Removed Node: ${NODE} at Instance ID: ${NODEID} from ${EKS_CLUSTER_NAME}"

            # Sleep 2 minutes to allow time for new cilium cni based node to join the cluster
            sleep 120

      else
            echo "NO NODES WITH LABEL cni-plugin=aws"
      fi
  done

  # Remove aws-node daemonset
  kubectl delete daemonset aws-node -n kube-system

  # Install Prometheus Grafana Dashboard
  kubectl apply -f yaml/prometheus-grafana-monitoring.yaml

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