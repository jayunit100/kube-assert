#!/bin/bash

while true; do
	sh kube-create.sh > "test_logs/kube_tests"$(date +'%m-%d-%Y_%T')".log"
done
