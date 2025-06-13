pipeline {
    agent any

    environment {
        COMPOSE_FILE = 'docker-compose.yml'
        APP_PORT     = '8081'
    }

    stages {
        // stage('Check Compose file') {
        //     steps {
        //         script {
        //             if (!fileExists(env.COMPOSE_FILE)) {
        //                 error "❌ Не знайдено файл ${env.COMPOSE_FILE}"
        //             }
        //         }
        //     }
        // }

        stage('Build containers') {
            steps {
                script {
                    def result = sh(script: 'docker ps', returnStatus: true)
                    if (result != 0) {
                        error("❌ Jenkins не має доступу до Docker. Додай користувача до групи docker.")
                    }
                    sh 'docker build -t app .'
                }
            }
        }

        // stage('Run tests') {
        //     when {
        //         expression { fileExists('tests') }
        //     }
        //     steps {
        //         script {
        //             def testStatus = sh(script: 'docker-compose run --rm web pytest', returnStatus: true)
        //             if (testStatus != 0) {
        //                 echo "⚠️ Тести завершились з помилкою, але пайплайн продовжується."
        //             }
        //         }
        //     }
        // }

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
            echo "✅ Деплой успішний: додаток доступний на http://<host>:${env.APP_PORT}"
        }
        failure {
            echo "❌ Щось пішло не так — перевір логи Jenkins stage‑ів та docker compose."
        }
        cleanup {
            script {
                try {
                    sh 'docker image prune -af || true'
                } catch (e) {
                    echo "⚠️ Не вдалося очистити образи: ${e.message}"
                }
            }
        }
    }
}
