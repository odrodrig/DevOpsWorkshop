#!/bin/bash

iks_login(){
    ibmcloud login
}

iks_create(){
    if ! ibmcloud cs clusters | grep 'mycluster' > /dev/null; then
        echo "Cluster does not exist, creating new cluster"
        ibmcloud cs cluster-create --name mycluster
    fi
    while [[ "$(ibmcloud ks clusters | awk '/mycluster/ { print $3 }')" != "normal" ]]; do
        echo "Cluster is not ready yet."
        sleep 60
    done
    echo "Cluster is ready."
}

configure_cluster(){
    if ! exp=$(ibmcloud ks cluster-config mycluster | grep export); then
        echo "Configuring kubectl failed."
        exit 1
    fi
    eval "$exp"
}

deploy_jenkins(){
    if ! kubectl get deployments | grep 'jenkins' > /dev/null; then
        echo "Deploying Jenkins."
        kubectl create -f kube/jenkins.yaml
    fi
    while [[ $(kubectl get pods -l app=jenkins | grep -c Running) -ne 1 ]]; do
        echo "Jenkins is deploying."
        sleep 10
    done
    echo "Jenkins is ready."
}

get_login(){
    echo ""
     echo "Jenkins URL: http://$(ibmcloud ks workers --cluster mycluster | awk '{ print $2 }' | grep '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'):31234"
     #shellcheck disable=SC2046
     echo "Initial Jenkins admin password: $(kubectl logs $(kubectl get pods |  awk ' /jenkins/ { print $1 }') | grep -B 2 'initialAdminPassword' | head -1)"
     echo "Kubernetes URL: $(kubectl cluster-info | awk '/master/ { print $6 }')"
}

main(){
    iks_login
    iks_create
    configure_cluster
    deploy_jenkins
    sleep 10
    get_login
}

main
