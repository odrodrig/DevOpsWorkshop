//  Copyright 2018 IBM
//    Licensed under the Apache License, Version 2.0 (the "License");
//    you may not use this file except in compliance with the License.
//    You may obtain a copy of the License at
//        http://www.apache.org/licenses/LICENSE-2.0
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS,
//    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//    See the License for the specific language governing permissions and
//    limitations under the License.
// def registryCredsID = env.REGISTRY_CREDENTIALS ?: "registry_credentials"
// pipeline {
//     agent any
//     stages {
//         stage ('test') {
//             agent {
//                 docker { image 'node:8' }
//             }
//             steps {
//                 sh '''
//                 #!/bin/bash
//                 cd nodeApp
//                 npm install
//                 npm test
//                 '''
//             }
//         }
//         stage ('Push') {
//             steps {
//                 withCredentials([usernamePassword(credentialsId: registryCredsID,
//                                                 usernameVariable: 'USERNAME',
//                                                 passwordVariable: 'PASSWORD')]) {
//                                                     sh '''
//                                                     #!/bin/bash
//                                                     cd nodeApp
//                                                     docker login -u "$USERNAME" -p "$PASSWORD"
//                                                     docker build -t "$USERNAME/$APP_NAME:$BUILD_NUMBER" .
//                                                     docker push "$USERNAME/$APP_NAME:$BUILD_NUMBER"
//                                                     '''
//                                                }
//             }
//         }
//         stage ('deploy') {
//             agent {
//                 docker { image 'ibmcom/ibm-cloud-developer-tools-amd64' }
//             }
//             steps {
//                 sh '''
//                 #!/bin/bash
//                 echo "$IBMCLOUD_API_KEY"
//                 ibmcloud login -a https://api.ng.bluemix.net
//                 ibmcloud cs clusters
                
//                 '''
//             }
//         }
//     }
// }

// Pod Template
def cloud = env.CLOUD ?: "kubernetes"
def registryCredsID = env.REGISTRY_CREDENTIALS ?: "registry-credentials-id"
def serviceAccount = env.SERVICE_ACCOUNT ?: "default"

// Pod Environment Variables
def namespace = env.NAMESPACE ?: "default"
def registry = env.REGISTRY ?: "mycluster.icp:8500"

podTemplate(label: 'mypod', cloud: cloud, serviceAccount: serviceAccount, namespace: namespace, envVars: [
        envVar(key: 'NAMESPACE', value: namespace),
        envVar(key: 'REGISTRY', value: registry)
    ],
    volumes: [
        hostPathVolume(hostPath: '/etc/docker/certs.d', mountPath: '/etc/docker/certs.d'),
        hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock')
],
    containers: [
        containerTemplate(name: 'kubectl', image: 'lachlanevenson/k8s-kubectl', ttyEnabled: true, command: 'cat'),
        containerTemplate(name: 'docker' , image: 'docker:17.06.1-ce', ttyEnabled: true, command: 'cat'),
        containerTemplate(name: 'node'   , image: 'node:8', ttyEnabled: true, comand: 'cat')
  ]) {

    node('mypod') {
        checkout scm
        container('node') {
            stage('test') {
                sh """
                #!/bin/bash
                cd nodeApp
                echo "Installing dependencies"
                npm install
                echo "Starting inting and unit testing"
                npm test
                """
            }
        }
        container('docker') {
            stage('Build Docker Image') {
                sh """
                #!/bin/bash
                NAMESPACE=`cat /var/run/configs/registry-config/namespace`
                REGISTRY=`cat /var/run/configs/registry-config/registry`

                docker build -t \${REGISTRY}/\${NAMESPACE}/${APP_NAME}:${env.BUILD_NUMBER} .
                """
            }
            stage('Push Docker Image to Registry') {
                sh """
                #!/bin/bash
                NAMESPACE=`cat /var/run/configs/registry-config/namespace`
                REGISTRY=`cat /var/run/configs/registry-config/registry`

                set +x
                DOCKER_USER=`cat /var/run/secrets/registry-account/username`
                DOCKER_PASSWORD=`cat /var/run/secrets/registry-account/password`
                docker login -u=\${DOCKER_USER} -p=\${DOCKER_PASSWORD} \${REGISTRY}
                set -x

                docker push \${REGISTRY}/\${NAMESPACE}/${APP_NAME}:${env.BUILD_NUMBER}
                """
            }
        }
        container('kubectl') {
            stage('Deploy new Docker Image') {
                sh """
                #!/bin/bash
                set +e
                NAMESPACE=`cat /var/run/configs/registry-config/namespace`
                REGISTRY=`cat /var/run/configs/registry-config/registry`
                DEPLOYMENT=`kubectl --namespace=\${NAMESPACE} get deployments -l app=${APP_NAME} -o name`

                kubectl --namespace=\${NAMESPACE} get \${DEPLOYMENT}

                if [ \${?} -ne "0" ]; then
                    # No deployment to update
                    echo 'No deployment to update'
                    exit 1
                fi

                # Update Deployment
                kubectl --namespace=\${NAMESPACE} set image \${DEPLOYMENT} web=\${REGISTRY}/\${NAMESPACE}/${APP_NAME}:${env.BUILD_NUMBER}
                kubectl --namespace=\${NAMESPACE} rollout status \${DEPLOYMENT}
                """
            }
        }
        //container for FVT
    }
}