#!/bin/bash
set -ex

DASHBOARD_ENABLED=${DASHBOARD_ENABLED:-false}

if [ ! DASHBOARD_ENABLED ]; then
    echo "skipping dashboard install"
    exit 0
fi

function install_dashboard() {
    # Add kubernetes-dashboard repository
    helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
    helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard
    # create Sample uesr
    # https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
EOF

    cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

    # create a token with the secret which bound the service account and the token will be saved in the Secret
    # using following command to get token
    # kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d
    # 也创建一个临时service account token
    # kubectl -n kubernetes-dashboard create token admin-user
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
  annotations:
    kubernetes.io/service-account.name: "admin-user"   
type: kubernetes.io/service-account-toke
EOF

    # accessing dashboard
    # kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443
    # visit by https://<IP:8444>
}
