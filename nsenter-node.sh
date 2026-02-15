#!/bin/sh
set -eu

# nsenter-node.sh — Enter a Kubernetes node's namespaces via a privileged pod.
# Usage: nsenter-node.sh <node-name> [kubectl-run-flags...]

usage() {
    echo "Usage: $(basename "$0") <node-name> [-- extra-kubectl-run-flags...]" >&2
    echo "" >&2
    echo "Enter a Kubernetes node by creating a temporary privileged pod" >&2
    echo "that uses nsenter to access all host namespaces." >&2
    exit 1
}

if [ $# -lt 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
fi

node="$1"
shift

# Resolve the node's hostname label (validates node exists)
nodeName=$(kubectl get node "$node" -o jsonpath='{.metadata.labels.kubernetes\.io/hostname}') || {
    echo "Error: node '$node' not found" >&2
    exit 1
}

if [ -z "$nodeName" ]; then
    echo "Error: could not resolve hostname for node '$node'" >&2
    exit 1
fi

# Build a safe pod name: lowercase, replace unsafe chars, truncate to 63 chars
currentUser="${USER:-nsenter}"
podName="${currentUser}-nsenter-${node}"
podName=$(echo "$podName" | tr '[:upper:]@.' '[:lower:]--' | sed 's/[^a-z0-9-]/-/g' | cut -c1-63 | sed 's/-$//')

echo "Creating pod '${podName}' on node '${nodeName}'..." >&2

kubectl run "${podName}" --restart=Never -it --rm --image=overridden --overrides="
{
  \"spec\": {
    \"hostPID\": true,
    \"hostNetwork\": true,
    \"nodeSelector\": {
      \"kubernetes.io/hostname\": \"${nodeName}\"
    },
    \"tolerations\": [{
      \"operator\": \"Exists\"
    }],
    \"containers\": [
      {
        \"name\": \"nsenter\",
        \"image\": \"alexeiled/nsenter\",
        \"command\": [\"/nsenter\", \"--all\", \"--target=1\", \"--\", \"su\", \"-\"],
        \"stdin\": true,
        \"tty\": true,
        \"securityContext\": {
          \"privileged\": true
        },
        \"resources\": {
          \"requests\": {
            \"cpu\": \"10m\"
          }
        }
      }
    ]
  }
}" --attach "$@"
