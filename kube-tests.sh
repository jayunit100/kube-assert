#!/bin/bash

passing=0
failing=0
NS="testing"

function assert() {
	if [[ $1 -eq $2 ]]
	then
		printf "%-30s\t\e[1;32m%-7s\e[0m\n" ${FUNCNAME[1]} "Success"
		((passing+=1))
	else
		printf "%-30s\t\e[1;31m%-7s\e[0m\t%s\n" ${FUNCNAME[1]} "Fail" "$3"
		printf "\tExpected [%s] got [%s]\n" $1 $2
		((failing+=1))
	fi
}

function assertGT() {
	if [[ $1 -gt $2 ]]
	then
		printf "%-30s\t\e[1;32m%-7s\e[0m\n" ${FUNCNAME[1]} "Success"
		((passing+=1))
	else
		printf "%-30s\t\e[1;31m%-7s\e[0m\t%s\n" ${FUNCNAME[1]} "Fail" "$3"
		printf "\tExpected [%s] to be greater than [%s]\n" $1 $2
		((failing+=1))
	fi
}

function testAllContainersRun() {
	runningCount=$(kubectl get pods --namespace=$NS | grep Running | awk '{print $3}' | wc -l)
	assert 8 $runningCount "Expect to see 8 pods running"
}

function testDbStart() {
	pod=$(kubectl get pods --namespace=$NS | grep postgres | awk '{print $1}')
	r=$(kubectl logs --namespace=$NS $pod | grep 'Attempting to start Hub database' | wc -l)
	assert 1 $r "Expect to see message indicateing the hub db started"
}

function testWebAppDbConect() {
	pod=$(kubectl get pods --namespace=$NS | grep nginx | awk '{print $1}')
	runningCount=$(kubectl logs --namespace=$NS $pod -c webapp | grep 'WARN  com.blackducksoftware.core.db.impl.HubDatabaseInitializer - Unable to manage connection' | wc -l)
	assert 0 $runningCount "pg_hba.conf should not reject connection"
}

function testWebAppDbUser() {
	pod=$(kubectl get pods --namespace=$NS | grep nginx | awk '{print $1}')
	r=$(kubectl logs --namespace=$NS $pod -c webapp | grep -E 'rejects connection for host .+ user "blackduck", database "bds_hub' | wc -l)
	assert 0 $r "user blackduck should not be rejected by the db"
}

function testDbFilebeatStart() {
	pod=$(kubectl get pods --namespace=$NS | grep postgres | awk '{print $1}')
	r=$(kubectl logs --namespace=$NS $pod | grep 'Filebeat started successfully' | wc -l)
	assert 1 $r "Expect to see message indicateing the hub db started"
}

function testNginxStarts() {
	pod=$(kubectl get pods --namespace=$NS | grep nginx | awk '{print $1}')
	r=$(kubectl logs --namespace=$NS $pod -c nginx | grep 'Attempting to start webserver' | wc -l)
	assert 1 $r "Should see a log message that nginx is listening"
}

function testLogstashContainsLogs() {
	pod=$(kubectl get pods --namespace=$NS | grep nginx | awk '{print $1}')
	r=$(kubectl logs --namespace=$NS $pod -c nginx | grep 'Attempting to start webserver' | wc -l)
	assert 1 $r "Should see a log message that nginx is listening"
}

function testZookeeper() {
	pod=$(kubectl get pods --namespace=$NS | grep zookeeper | awk '{print $1}')
	r=$(kubectl logs --namespace=$NS $pod | grep 'binding to port 0.0.0.0/0.0.0.0:2181' | wc -l)
	assert 1 $r "Should see a log message that zookeeper has bound to its port"
}

function main() {
	tests=$(grep "^function\ test" $0 | awk '{print $2 }')
		for test in $tests; do
			${test//\(\)}
	done

		printf "\n\nSummary:\nPassing:\t%s\nFailing:\t%s\n\n" $passing $failing
}

main

