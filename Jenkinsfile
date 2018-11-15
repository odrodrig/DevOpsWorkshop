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
                ls
                cd nodeApp
                docker build -t ${env.REGISTRY}/${env.NAMESPACE}/${IMAGE_NAME}:${env.BUILD_NUMBER} .
                """
            }
            stage('Push Docker Image to Registry') {
                withCredentials([usernamePassword(credentialsId: registryCredsID,
                                               usernameVariable: 'USERNAME',
                                               passwordVariable: 'PASSWORD')]) {
                    sh """
                    #!/bin/bash
                    docker login -u ${USERNAME} -p ${PASSWORD} ${env.REGISTRY}
                    docker push ${env.REGISTRY}/${env.NAMESPACE}/${env.IMAGE_NAME}:${env.BUILD_NUMBER}
                    """
                }
            }
        }
        container('kubectl') {
            stage('Deploy new Docker Image') {
                sh """
                #!/bin/bash
                DEPLOYMENT=`kubectl --namespace=${env.NAMESPACE} get deployments -l app=${env.APP_NAME} -o name`
                kubectl --namespace=${env.NAMESPACE} get \${DEPLOYMENT}

                echo "${env.BRANCH_NAME}"
                echo "${BRANCH_NAME}"

                if [ ${env.BRANCH_NAME} -eq "test" ]; then
                    DEPLOYMENT=`kubectl --namespace=${env.NAMESPACE} get deployments -l app="${env.APP_NAME}-test" -o name`
                    echo 'In test branch. Deploying to test env'
                    kubectl --namespace=${env.NAMESPACE} set image \${DEPLOYMENT} \${DEPLOYMENT}=${env.REGISTRY}/${env.NAMESPACE}/${env.IMAGE_NAME}:${env.BUILD_NUMBER}

                elif [ ${env.BRANCH_NAME} -eq "master" ]; then
                    DEPLOYMENT=`kubectl --namespace=${env.NAMESPACE} get deployments -l app=${env.APP_NAME} -o name`
                    echo 'In master branch. Deploying to prod env'
                    kubectl --namespace=${env.NAMESPACE} set image \${DEPLOYMENT} \${DEPLOYMENT}=${env.REGISTRY}/${env.NAMESPACE}/${env.IMAGE_NAME}:${env.BUILD_NUMBER}
                fi

                if [ \${?} -ne "0" ]; then
                    # No deployment to update
                    echo 'No deployment to update'
                    exit 1
                fi


                # Update Deployment
                kubectl --namespace=${env.NAMESPACE} rollout status \${DEPLOYMENT}
                """
            }
        }
    }
}
