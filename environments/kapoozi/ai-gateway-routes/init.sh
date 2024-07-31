#!/bin/bash

echo "wave description:"
echo "deploy ai-gateway routes"

# Create argo app-of-apps project
kubectl apply --context ${cluster_context} -f- <<EOF
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: ai-gateway-routes
  namespace: argocd
spec:
  clusterResourceWhitelist:
  - group: '*'
    kind: '*'
  destinations:
  - namespace: '*'
    server: '*'
  sourceRepos:
  - '*'
EOF