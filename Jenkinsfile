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
                sh '''
                    docker compose version || docker --version || apt-get update && apt-get install -y docker-compose
                    docker compose build
                '''
            }
        }

        stage('Run tests') {
            when {
                expression { fileExists('tests') }
            }
            steps {
                sh 'docker compose run --rm web pytest || true'
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    docker compose down || true
                    docker compose up -d --remove-orphans
                '''
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
                    echo "⚠ Не вдалося очистити образи: ${e.message}"
                }
            }
        }
    }
}
