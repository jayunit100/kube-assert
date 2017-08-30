#!/bin/bash
set -e

# git clone ssh://git@bitbucket.dc1.lan:7999/hub/rest-backend.git
# cd ./docker/hub-docker/src/main/dist/kubernetes

### modify this line with your specific testing stuff.
source examples/hub/source.sh

kubectl create -f namespace.json
kubectl create -f pods-testing.env --namespace=$NS

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
sleep $SLEEP_INTERVAL

sh ./kube-tests.sh

# TODO comment why we comment this out :)
# kubectl delete -f namespace.json
