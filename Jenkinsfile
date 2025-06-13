pipeline {
    agent {
        docker {
            image 'docker:25.0.2-cli'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

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

        stage('Install Compose & Build') {
            steps {
                sh '''
                    docker compose version || apk add --no-cache docker-cli docker-compose
                    docker compose build
                '''
            }
        }

        stage('Test (optional)') {
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
            sh 'docker image prune -af || true'
        }
    }
}
