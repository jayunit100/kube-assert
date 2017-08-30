#!/bin/bash
set -e

# git clone ssh://git@bitbucket.dc1.lan:7999/hub/rest-backend.git
# cd ./docker/hub-docker/src/main/dist/kubernetes

NS="testing"
NODENAME="kubernetes-minion-group-b2s6"

kubectl create -f namespace.json
kubectl create -f pods-testing.env --namespace=$NS
kubectl label --overwrite nodes $NODENAME blackduck.hub.postgres=true --namespace=$NS

sudo rm -rf /var/lib/hub-postgresql
sudo mkdir -p /var/lib/hub-postgresql/data 
sudo chmod -R 775 /var/lib/hub-postgresql/data

kubectl create -f kubernetes-pre-db.yml.template --namespace=$NS
until [ $(kubectl get pods --namespace=$NS | awk '{ print $3 }' | grep Running | wc -l) -eq 2 ]; do
	sleep 2
done
 
kubectl create -f kubernetes-post-db.yml.template --namespace=$NS
until [ $(kubectl get pods --namespace=$NS | awk '{ print $3 }' | grep Running | wc -l) -eq 8 ];
do
	sleep 2
done

# sleep to allow everything to actually spin up before beginning testing
sleep 1m
 
sh ./kube-tests.sh

# kubectl delete -f namespace.json
