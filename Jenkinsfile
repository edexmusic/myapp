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
                        error("Jenkins не має доступу до Docker. Додай користувача до групи docker.")
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
            echo "Деплой успішний: додаток доступний на http://<host>:${env.APP_PORT}"
        }
        failure {
            echo "Щось пішло не так — перевір логи Jenkins stage‑ів та docker compose."
        }
        cleanup {
            script {
                try {
                    sh 'docker image prune -af || true'
                } catch (e) {
                    echo "Не вдалося очистити образи: ${e.message}"
                }
            }
        }
    }
}
