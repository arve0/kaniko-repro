#!/usr/bin/env bash
set -eo pipefail

function cleanup {
  kubectl delete pod kaniko
}
trap cleanup EXIT

kubectl apply -f registry.yaml

function pod-running {
  kubectl get pods -n default "$@" | grep Running &> /dev/null
}

until pod-running -l app=registry; do
  echo -n .
done
echo
set -x

kubectl version
kubectl run kaniko --restart=Never --image=gcr.io/kaniko-project/executor:debug -- \
  --log-format=text \
  --verbosity=trace \
  --log-timestamp \
  --context=git://github.com/arve0/kaniko-repro \
  --insecure-registry=registry.default \
  --destination=registry.default/arve0/kaniko-repro \
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
