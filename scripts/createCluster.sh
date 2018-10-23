#!/bin/bash

if [ "$IBMCLOUD_API_KEY" ]; then
    ibmcloud login -a https://api.ng.bluemix.net
else 
    echo 'API key is not set. Please set IBMCLOUD_API_KEY with your IBM Cloud API key'
    exit 1
fi

if ! ibmcloud cs clusters | grep 'mycluster' ; then
    echo 'Cluster does not exist, creating new cluster'
    ibmcloud cs cluster-create --name mycluster 
else
    echo 'Cluster exists'
fi

