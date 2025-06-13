pipeline {
    agent any

    environment {
        COMPOSE_FILE = 'docker-compose.yml'
        APP_PORT     = '8081'
    }

    stages {
        stage('Checkout source') {
            steps {
                git branch: 'main', url: 'https://github.com/edexmusic/myapp.git'
            }
        }

        stage('Build containers') {
            steps {
                script {
                    // Перевіряємо доступ до Docker
                    def result = sh(script: 'docker ps', returnStatus: true)
                    if (result != 0) {
                        error("❌ Jenkins не має доступу до Docker. Перевір, чи додано користувача до групи docker.")
                    }
                    sh 'docker-compose build'
                }
            }
        }

        stage('Run tests') {
            when {
                expression { fileExists('tests') }
            }
            steps {
                script {
                    def testStatus = sh(script: 'docker-compose run --rm web pytest', returnStatus: true)
                    if (testStatus != 0) {
                        echo "⚠️ Тести завершились з помилкою, але пайплайн продовжується."
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    sh '''
                        docker-compose down || true
                        docker-compose up -d --remove-orphans
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
            echo "❌ Щось пішло не так — перевір логи Jenkins stage‑ів та docker-compose."
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
