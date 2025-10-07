pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'daivalokesh/my-django-application'
        GIT_REPO = 'https://github.com/DaivaLokesh/CapstoneProject.git'
        TEST_REPORT_DIR = 'test-reports'
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: "${GIT_REPO}"
            }
        }

        stage('Setup Python & Install Dependencies') {
            steps {
                sh '''
                python -m venv venv
                source venv/bin/activate
                pip install --upgrade pip
                pip install -r requirements.txt
                '''
            }
        }

        stage('Run Tests') {
            steps {
                sh '''
                mkdir -p ${TEST_REPORT_DIR}
                pytest --junitxml=${TEST_REPORT_DIR}/results.xml > ${TEST_REPORT_DIR}/test_output.log 2>&1 || true
                '''
                junit "${TEST_REPORT_DIR}/results.xml"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Only rebuild if Dockerfile or requirements.txt changed
                    def changed = sh(script: "git diff --name-only HEAD~1 HEAD | grep -E 'Dockerfile|requirements.txt' || true", returnStdout: true).trim()
                    if (changed) {
                        echo "Changes detected in Dockerfile/requirements.txt. Building Docker Image..."
                        sh "docker build -t ${DOCKER_IMAGE} ."
                    } else {
                        echo "No relevant changes. Skipping Docker build."
                    }
                }
            }
        }

        stage('Docker Login & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh "echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin"
                    script {
                        sh "docker push ${DOCKER_IMAGE}"
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                docker stop django_app || true
                docker rm django_app || true
                docker run -d --name django_app -p 8000:8000 ${DOCKER_IMAGE}
                '''
            }
        }

        stage('Monitor Application') {
            steps {
                echo "Performing simple health check..."
                sh '''
                curl -f http://localhost:8000/health/ || echo "Health check failed"
                '''
            }
        }
    }

    post {
        always {
            echo "Cleaning up local Docker images..."
            sh "docker rmi ${DOCKER_IMAGE} || true"
            archiveArtifacts artifacts: 'test-reports/**', allowEmptyArchive: true
        }
        failure {
            echo "Pipeline failed. Check test reports for failed tests."
        }
    }
}
