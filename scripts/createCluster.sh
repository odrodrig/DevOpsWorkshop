#!/bin/bash

iks_login(){
    ibmcloud login -a https://api.ng.bluemix.net
}

iks_create(){
    if ! ibmcloud cs clusters | grep 'mycluster' ; then
        echo 'Cluster does not exist, creating new cluster'
        ibmcloud cs cluster-create --name mycluster
    else
        echo 'Cluster exists'
    fi
}

main(){
    iks_login
    iks_create
}

main
