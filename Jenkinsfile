pipeline {
    agent {
        docker {
            image 'python:3.12-slim'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    environment {
        DOCKER_IMAGE = 'daivalokesh/my-django-application'
        GIT_REPO = 'https://github.com/DaivaLokesh/CapstoneProject.git'
        TEST_REPORT_DIR = 'test-reports'
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'master', url: "${GIT_REPO}"
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                pip install --upgrade pip
                pip install -r requirements.txt
                '''
            }
        }

        stage('Run Tests') {
            steps {
                sh '''
                mkdir -p ${TEST_REPORT_DIR}
                pytest --junitxml=${TEST_REPORT_DIR}/results.xml --html=${TEST_REPORT_DIR}/report.html > ${TEST_REPORT_DIR}/test_output.log 2>&1 || true
                '''
                junit "${TEST_REPORT_DIR}/results.xml"
                publishHTML(target: [
                    reportDir: TEST_REPORT_DIR,
                    reportFiles: 'report.html',
                    reportName: 'HTML Test Report',
                    keepAll: true,
                    alwaysLinkToLastBuild: true
                ])
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
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
                    sh "docker push ${DOCKER_IMAGE}"
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
            echo "Cleaning up workspace..."
            archiveArtifacts artifacts: 'test-reports/**', allowEmptyArchive: true
        }
        failure {
            echo "Pipeline failed. Check test reports for failed tests."
        }
    }
}
