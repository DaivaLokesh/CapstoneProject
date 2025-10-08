pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'daivalokesh/my-django-application'
        GIT_REPO = 'https://github.com/DaivaLokesh/cddProject.git'
    }

    stages {
        stage('Clone Repository') {
    steps {
        git branch: 'master', url: 'https://github.com/DaivaLokesh/CapstoneProject.git'
        }
    }
        stage('Run Tests') {
            steps {
                sh 'pytest --junitxml=reports/test-results.xml --maxfail=1 --disable-warnings'
            }
            post {
                always {
                    junit 'reports/test-results.xml'
                }
            }
        }

        stage('Build Docker Image') {
            when {
                expression { currentBuild.result == null || currentBuild.result == 'SUCCESS' }
            }
            steps {
                sh '''
                  docker pull myuser/myapp:latest || true
                  docker build --cache-from=myuser/myapp:latest -t myuser/myapp:latest .
                  docker push myuser/myapp:latest
                '''
            }
        }
    

        stage('Docker Login') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        echo "Logging into Docker Hub..."
                        sh "echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin"
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    echo "Pushing Docker Image to Hub: ${DOCKER_IMAGE}"
                    sh "docker push ${DOCKER_IMAGE}"
                }
            }
        }
    }

    post {
        always {
            echo "Cleaning up local Docker images..."
            sh "docker rmi ${DOCKER_IMAGE} || true"
        }
    }
}
