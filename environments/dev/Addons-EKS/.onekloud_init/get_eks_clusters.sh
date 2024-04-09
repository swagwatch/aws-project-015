#!/bin/bash

# JSONArray VARIABLE
clusterArray=[

# READ ALL CLUSTER NAMES INTO THIS ARRAY
allClusters=($(cat cluster_names.txt))

# GET TOTAL NUMBER OF CLUSTERS
totalClusters=${#allClusters[@]}

# SET CLUSTER INDEX
clusterIndex=1

# BUILD JSON ARRAY
for cluster in ${allClusters[@]}; do
  if [ "$clusterIndex" -lt "$totalClusters" ] 
  then
     clusterArray=${clusterArray}\"${cluster}\",
  elif [ "$clusterIndex" -eq "$totalClusters" ] 
  then
     clusterArray=${clusterArray}\"${cluster}\"
  fi
  clusterIndex=$((clusterIndex+1))
done

clusterArray=${clusterArray}]

# WRITE JSON ARRAY TO A FILE
echo $clusterArray > eks_clusters.json

# VIEW CONTENTS OF eks_clusters.json
cat eks_clusters.json
