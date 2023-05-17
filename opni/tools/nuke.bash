#!/usr/bin/env bash
# Nuke the opni cluster, and effectively everying in th eopni namespace

namespace=opni

helm uninstall --namespace $namespace opni
helm uninstall --namespace $namespace opni-crd

kubectl delete --namespace $namespace                          \
	$(kubectl --namespace $namespace get all --output name)    \
	$(kubectl --namespace $namespace get pvc --output name)    \
	$(kubectl --namespace $namespace get secret --output name) \
	$(kubectl get crd --output name | grep -E 'opni|coreos')     # causes problems for rancher-monitoring
