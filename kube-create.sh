#!/bin/bash
set -e

# git clone ssh://git@bitbucket.dc1.lan:7999/hub/rest-backend.git
# cd ./docker/hub-docker/src/main/dist/kubernetes

NS="testing"
NODENAME="kubernetes-minion-group-b2s6"

## TODO Move these definitions into examples/ so this is kube generic.
CREATE_FILE_1="kubernetes-pre-db.yml.template"
CREATE_FILE_1_PODS="2"
CREATE_FILE_2="kubernetes-post-db.yml.template"
CREATE_FILE_2_PODS="8"

kubectl create -f namespace.json
kubectl create -f pods-testing.env --namespace=$NS

## TODO Somehow make label operations kube generic.
kubectl label --overwrite nodes $NODENAME blackduck.hub.postgres=true --namespace=$NS

sudo rm -rf /var/lib/hub-postgresql
sudo mkdir -p /var/lib/hub-postgresql/data 
sudo chmod -R 775 /var/lib/hub-postgresql/data


# TODO Make this a for loop with N create files.
kubectl create -f $CREATE_FILE_1 --namespace=$NS
until [ $(kubectl get pods --namespace=$NS | awk '{ print $3 }' | grep Running |
    wc -l) -eq $CREATE_FILE_1_PODS ]; do
	sleep 2
done
 
kubectl create -f $CREATE_FILE_2 --namespace=$NS
until [ $(kubectl get pods --namespace=$NS | awk '{ print $3 }' | grep Running |
    wc -l) -eq $CREATE_FILE_2_PODS ];
do
	sleep 2
done

# sleep to allow everything to actually spin up before beginning testing
sleep 1m
 
sh ./kube-tests.sh

# TODO comment why we comment this out :)
# kubectl delete -f namespace.json
