/** Jenkinsfile
 *  Автоматизує збірку, тестування, пуш (необовʼязково) та деплой Flask‑додатка.
 *  Працює з docker compose v2 (команда `docker compose ...`).
 */
pipeline {
    /* --- 1. Де виконується pipeline --- */
    agent {
        /* Варіант а) На Jenkins‑агенті вже встановлено docker.
         * Варіант б) Запускаємо одноразовий контейнер з docker‑CLI усередині:
         *
         * docker.image('docker:25.0-cli').inside('-v /var/run/docker.sock:/var/run/docker.sock') { ... }
         *
         * Якщо використовуєш другий варіант, перенеси всі stage‑и всередину блоку inside { }.
         */
        label 'docker-enabled'   // заміни на свій label або прибери, якщо не потрібен
    }

    /* --- 2. Глобальні змінні середовища --- */
    environment {
        // Якщо плануєш пушити образи в Docker Hub або інший реєстр
        REGISTRY_CREDENTIALS = 'docker-hub-creds'   // ID Jenkins‑credentials (user/password або token)
        IMAGE_NAME           = 'yourusername/myapp' // заміни на власний namespace/repo
        IMAGE_TAG            = "${env.BUILD_NUMBER}"// тег = номер білда
        COMPOSE_FILE         = 'docker-compose.yml' // за замовчуванням у корені repo
        // змінна PORT, якщо треба гнучко міняти мапінг
        APP_PORT             = '8080'
    }

    /* --- 3. Етапи --- */
    stages {

        stage('Checkout source') {
            steps {
                // Якщо це багатогілковий проєкт — git url прописувати не треба
                git branch: 'main',
                    url: 'https://github.com/<your‑org>/myapp.git'
            }
        }

        stage('Build Docker image') {
            steps {
                // Будуємо образи, визначені в docker‑compose (web, db тощо)
                sh '''
                    docker compose build
                '''
            }
        }

        /* Якщо у тебе є юніт‑тести — проганяємо їх усередині контейнера */
        stage('Run tests (optional)') {
            when {
                expression { fileExists('tests') }   // запускаємо тільки, якщо папка tests існує
            }
            steps {
                sh '''
                    # Виконуємо pytest у одноразовому контейнері
                    docker compose run --rm web pytest
                '''
            }
        }

        /* Пуш у Docker Hub / registry */
        stage('Push image to registry') {
            when {
                expression { return env.REGISTRY_CREDENTIALS?.trim() }
            }
            steps {
                withCredentials([usernamePassword(
                        credentialsId: env.REGISTRY_CREDENTIALS,
                        usernameVariable: 'REG_USER',
                        passwordVariable: 'REG_PASS')]) {

                    sh '''
                        # Тегуємо головний сервіс (web) і пушимо
                        docker tag myapp_web:latest $IMAGE_NAME:$IMAGE_TAG
                        echo "$REG_PASS" | docker login -u "$REG_USER" --password-stdin
                        docker push $IMAGE_NAME:$IMAGE_TAG
                        docker logout
                    '''
                }
            }
        }

        /* Перезапуск (деплой) */
        stage('Deploy') {
            steps {
                // Зупиняємо попередні контейнери (якщо є) і піднімаємо нові
                sh '''
                    docker compose down
                    # Можна задати власний проектний нейм, щоб уникати конфліктів портів
                    docker compose --project-name myapp -p myapp \
                        up -d --remove-orphans
                '''
            }
        }
    }

    /* --- 4. Післябілдові дії --- */
    post {
        success {
            echo "✅ Деплой успішний: додаток доступний на http://<host>:${env.APP_PORT}"
        }
        failure {
            echo "❌ Щось пішло не так — перевір логи Jenkins stage‑ів та docker compose."
        }
        cleanup {
            // Видаляємо непотрібні висячі образи, щоб не захаращувати disk
            sh 'docker image prune -af || true'
        }
    }
}
