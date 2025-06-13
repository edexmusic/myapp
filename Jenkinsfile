pipeline {
    agent {
        dockerContainer {
            image 'docker:25.0-cli'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    environment {
        REGISTRY_CREDENTIALS = 'docker-hub-creds'
        IMAGE_NAME           = 'yourusername/myapp'
        IMAGE_TAG            = "${env.BUILD_NUMBER}"
        COMPOSE_FILE         = 'docker-compose.yml'
        APP_PORT             = '8080'
    }

    stages {
        stage('Checkout source') {
            steps {
                git branch: 'main', url: 'https://github.com/edexmusic/myapp.git'
            }
        }

        stage('Build Docker image') {
            steps {
                sh 'docker compose build'
            }
        }

        stage('Run tests (optional)') {
            when { expression { fileExists('tests') } }
            steps {
                sh 'docker compose run --rm web pytest'
            }
        }

        stage('Push image to registry') {
            when { expression { return env.REGISTRY_CREDENTIALS?.trim() } }
            steps {
                withCredentials([usernamePassword(
                        credentialsId: env.REGISTRY_CREDENTIALS,
                        usernameVariable: 'REG_USER',
                        passwordVariable: 'REG_PASS')]) {
                    sh '''
                        docker tag myapp_web:latest $IMAGE_NAME:$IMAGE_TAG
                        echo "$REG_PASS" | docker login -u "$REG_USER" --password-stdin
                        docker push $IMAGE_NAME:$IMAGE_TAG
                        docker logout
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    docker compose down
                    docker compose --project-name myapp -p myapp up -d --remove-orphans
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
