#!/usr/bin/env bash
set -euo pipefail
NODE="${1:?Usage: drain.sh worker-node}"
CONTEXT="$(kubectl config current-context)"
[[ "$CONTEXT" == "kind-ha-lab" ]] || { echo "Select the disposable kind-ha-lab context first"; exit 1; }
[[ "$NODE" == ha-lab-worker* ]] || { echo "Only disposable lab workers are permitted"; exit 1; }
mkdir -p results
trap 'kubectl uncordon "$NODE"' EXIT
kubectl get pods -n ha-lab -o wide | tee results/before.txt
# Redis minAvailable=1 deliberately prevents draining its node; do not override the PDB.
kubectl drain "$NODE" --ignore-daemonsets --delete-emptydir-data --timeout=90s 2>&1 | tee results/drain.txt
kubectl rollout status deployment/api -n ha-lab --timeout=90s
kubectl get pods -n ha-lab -o wide | tee results/after.txt
