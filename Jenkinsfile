pipeline {

    def registryCredsID = env.REGISTRY_CREDENTIALS ?: "registry-credentials-id"

    agent none
    stages {
        stage ('test') {
            agent {
                docker { image 'node:8' }
            }
            steps {
                sh '''
                ls
                cd nodeTest
                npm install
                npm test
                '''
            }
        }
        stage ('Push') {
            withCredentials([usernamePassword(credentialsId: registryCredsID,
                                               usernameVariable: 'USERNAME', 
                                               passwordVariable: 'PASSWORD')]) {
                                                   sh '''
                                                    docker login -u ${USERNAME} -p ${PASSWORD}
                                                    docker push ${USERNAME}/node-test:${env.BUILD_NUMBER}
                                                    '''

                                               }

        }
        stage ('deploy') {
            agent any
            steps {
                sh '''
                docker version

                if [ docker ps -f name=node-test ] then
                   docker kill node-test
                   docker rm node-test
                   docker run -d -p 8080:8080 --name node-test odrodrig/node-test:latest
                else
                    docker run -d -p 8080:8080 --name node-test odrodrig/node-test:latest
                fi 
                docker ps
                '''
            }
        }
    }
}