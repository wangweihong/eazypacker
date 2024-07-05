#!/usr/bin/bash 


curl https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.43.2/release.yaml -o pipeline.yaml
curl https://storage.googleapis.com/tekton-releases/dashboard/previous/v0.31.0/tekton-dashboard-release.yaml -o tekton-dashboard-release.yaml

# kubectl port-forward --address 0.0.0.0 svc/tekton-dashboard 8097:9097 -n tekton-pipelines