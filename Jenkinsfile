pipeline {
    agent any

    environment {
        COMPOSE_FILE = 'docker-compose.yml'
        APP_PORT     = '8081'
    }

    stages {
        stage('Build containers') {
            steps {
                script {
                    def result = sh(script: 'docker ps', returnStatus: true)
                    if (result != 0) {
                        error("Jenkins does not have access to Docker. Add the user to the docker group.")
                    }
                    sh 'docker build -t app .'
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    sh '''
                        docker rm -f app-container || true
                        docker run -p 8082:80 -d --name app-container app 
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Deployment successful: application available at http://<host>:${env.APP_PORT}"
        }
        failure {
            echo "Something went wrong - check Jenkins stage and docker compose logs."
        }
        cleanup {
            script {
                try {
                    sh 'docker image prune -af || true'
                } catch (e) {
                    echo "Failed to clear images: ${e.message}"
                }
            }
        }
    }
}
