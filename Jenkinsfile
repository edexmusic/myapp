pipeline {
    agent any

    environment {
        REPO_URL     = 'https://github.com/edexmusic/myapp.git'
        BRANCH       = 'main'
        APP_DIR      = 'myapp'
        COMPOSE_FILE = 'docker-compose.yml'
        APP_PORT     = '8081'
    }

    stages {
        stage('Checkout source') {
            steps {
        sh "rm -rf myapp"
        sh "git clone --branch main https://github.com/edexmusic/myapp.git myapp"
    }
        }

        stage('Check Compose file') {
            steps {
                script {
                    if (!fileExists("${env.APP_DIR}/${env.COMPOSE_FILE}")) {
                        error "❌ Не знайдено файл ${env.COMPOSE_FILE} у ${env.APP_DIR}"
                    }
                }
            }
        }

        stage('Build containers') {
            steps {
                script {
                    def result = sh(script: 'docker ps', returnStatus: true)
                    if (result != 0) {
                        error("❌ Jenkins не має доступу до Docker. Додай користувача до групи docker.")
                    }
                    sh "cd ${env.APP_DIR} && docker compose build"
                }
            }
        }

        stage('Run tests') {
            when {
                expression { fileExists("${env.APP_DIR}/tests") }
            }
            steps {
                script {
                    def testStatus = sh(script: "cd ${env.APP_DIR} && docker compose run --rm web pytest", returnStatus: true)
                    if (testStatus != 0) {
                        echo "⚠️ Тести завершились з помилкою, але пайплайн продовжується."
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    sh """
                        cd ${env.APP_DIR}
                        docker compose down || true
                        docker compose up -d --remove-orphans
                    """
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
