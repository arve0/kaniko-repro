#!/usr/bin/env bash
set -eo pipefail

function cleanup {
  kubectl delete pod kaniko
}
trap cleanup EXIT

function pod-running {
  kubectl get pods -n default "$@" | grep Running &> /dev/null
}

set -x
kubectl version
kubectl run kaniko --restart=Never --image=gcr.io/kaniko-project/executor:debug -- \
  --log-format=text \
  --log-timestamp \
  --context=git://github.com/arve0/kaniko-repro \
  --destination=registry.linode.arve.dev/arve0/kaniko-repro \
  --force # force is required on linode, as runc detection does not work correctly

# by some reason, kubectl run -it does not allways give logs
# get with kubectl logs when pod has started
set +x
until pod-running kaniko; do
  echo -n .
done
echo
set -x
kubectl logs -f kaniko
