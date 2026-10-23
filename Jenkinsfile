// Pipeline CI/CD du site Les Loups du Game
// Jenkins sous Windows : commandes via bat et powershell.
pipeline {
    agent any

    options {
        skipDefaultCheckout(true)                       // checkout fait dans l'étape dédiée
        buildDiscarder(logRotator(numToKeepStr: '10'))  // 10 builds conservés
        disableConcurrentBuilds()                       // un seul build à la fois (ports, conteneurs)
        timestamps()                                    // horodate le journal
    }

    triggers {
        pollSCM('H/2 * * * *')                          // vérifie GitHub toutes les 2 minutes
    }

    environment {
        // Version de l'image : 2.0.<numéro de build>. Prioritaire sur le fichier .env.
        LLDG_VERSION = "2.0.${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build image') {
            steps {
                powershell '''
                    $date = Get-Date -Format o
                    docker build --build-arg VERSION=$env:LLDG_VERSION --build-arg BUILD_DATE=$date -t "lldg:$env:LLDG_VERSION" .
                    if ($LASTEXITCODE -ne 0) { throw "Échec du build de l'image" }
                '''
            }
        }

        stage('Test HTTP') {
            steps {
                bat 'docker run -d --name lldg-test -p 8095:80 -e APP_ENV=test lldg:%LLDG_VERSION%'
                powershell '& ./tests/smoke.ps1 -BaseUrl http://localhost:8095'
            }
            post {
                always {
                    bat 'docker rm -f lldg-test || exit /b 0'
                }
            }
        }

        stage('Deploy Dev') {
            steps {
                bat 'docker compose -p lldg-dev -f docker-compose.yml -f docker-compose.dev.yml up -d --no-build'
            }
        }

        stage('Deploy Pré-prod') {
            when { expression { env.GIT_BRANCH == null || env.GIT_BRANCH.endsWith('main') } }
            steps {
                bat 'docker compose -p lldg-preprod -f docker-compose.yml -f docker-compose.preprod.yml up -d'
                powershell '& ./tests/smoke.ps1 -BaseUrl http://localhost:8082'
            }
        }

        stage('Recette') {
            when { expression { env.GIT_BRANCH == null || env.GIT_BRANCH.endsWith('main') } }
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    input message: "Recette validée sur http://localhost:8082 ? Déployer la version ${env.LLDG_VERSION} en production ?",
                          ok: 'Déployer en production'
                }
            }
        }

        stage('Deploy Prod') {
            when { expression { env.GIT_BRANCH == null || env.GIT_BRANCH.endsWith('main') } }
            steps {
                bat 'docker compose -p lldg-prod -f docker-compose.yml -f docker-compose.prod.yml up -d'
                powershell '& ./tests/smoke.ps1 -BaseUrl http://localhost:8080'
            }
        }
    }

    post {
        success {
            echo "Version ${env.LLDG_VERSION} déployée. Prod : http://localhost:8080"
        }
        failure {
            echo "Échec du build ${env.BUILD_NUMBER} : ouvrez Pipeline Overview pour voir l'étape en rouge."
        }
    }
}
