def registryCredsID = env.REGISTRY_CREDENTIALS ?: "registry-credentials"

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
                cd nodeTest
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
                                                    ls
                                                    cd nodeTest
                                                    docker login -u ${USERNAME} -p ${PASSWORD}
                                                    docker build -t $USERNAME/$APP_NAME:$BUILD_NUMBER .
                                                    docker push $USERNAME/$APP_NAME:$BUILD_NUMBER
                                                    '''
                                               }
            }
        }
        stage ('deploy') {
            agent any
            steps {
                sh '''
                #!/bin/bash
                docker version

                if [ docker ps -f name=APP_NAME ]; then
                   docker kill $APP_NAME
                   docker rm $APP_NAME
                fi 
                docker run -d -p 8080:8080 --name $APP_NAME $DOCKER_HUB_ACCOUNT/$APP_NAME:$BUILD_NUMBER
                docker ps
                '''
            }
        }
    }
}
