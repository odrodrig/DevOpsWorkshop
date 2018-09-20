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
def registryCredsID = env.REGISTRY_CREDENTIALS ?: "registry_credentials"
pipeline {
    agent any
    stages {
        stage ('test') {
            agent {
                docker { image 'node:8' }
            }
            steps {
                sh '''
                #!/bin/bash
                cd nodeApp
                npm install
                npm test
                '''
            }
        }
        stage ('Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: registryCredsID,
                                                usernameVariable: 'USERNAME',
                                                passwordVariable: 'PASSWORD')]) {
                                                    sh '''
                                                    #!/bin/bash
                                                    cd nodeApp
                                                    docker login -u "$USERNAME" -p "$PASSWORD"
                                                    docker build -t "$USERNAME/$APP_NAME:$BUILD_NUMBER" .
                                                    docker push "$USERNAME/$APP_NAME:$BUILD_NUMBER"
                                                    '''
                                               }
            }
        }
        stage ('deploy') {
            agent any
            steps {
                sh '''
                #!/bin/bash
                if docker ps -f name="$APP_NAME"; then
                   echo 'App exists, removing old container'
                   docker kill "$APP_NAME"
                   docker rm "$APP_NAME"
                fi
                docker run -d -p 8080:8080 --name "$APP_NAME $DOCKER_HUB_ACCOUNT/$APP_NAME:$BUILD_NUMBER"
                docker ps
                '''
            }
        }
    }
}
