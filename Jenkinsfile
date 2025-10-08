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
    stage('Test') {
    steps {
        sh '''
        pip install -r requirements.txt
        pytest --junitxml=reports/test-results.xml --cov=. --cov-report=xml:reports/coverage.xml
        '''
    }
    post {
        always {
            junit 'reports/test-results.xml'
        }
    }
}

      stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker Image: ${DOCKER_IMAGE}"
                    sh "docker build -t ${DOCKER_IMAGE} ."
                }
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
