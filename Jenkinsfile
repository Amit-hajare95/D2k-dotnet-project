pipeline {
    agent none   

    parameters {
        string(name: 'BRANCH', defaultValue: 'master', description: 'Git branch to clone')
        string(name: 'TAG', defaultValue: 'latest', description: 'Docker image tag')
        choice(name: 'ENV', choices: ['UAT', 'PROD'], description: 'Choose environment to deploy')
    }

    environment {
        DOCKER_CREDS = credentials('dockerhub-creds')   
        REPO = "amithajare5734/dotnet-hello-world"
        CLONE_DIR = "/var/lib/jenkins/workspace/dotnet-hello-world"  
    }

    stages {
        stage('Clone Project') {
            agent { label 'master' }   
            steps {
                sh '''
                  rm -rf /var/lib/jenkins/workspace/dotnet-hello-world dotnet-hello-world@tmp
                  git clone -b ${BRANCH} https://github.com/doddatpivotal/dotnet-hello-world.git ${CLONE_DIR}
                '''
            }
        }

        stage('Prepare Docker Files') {
            agent { label 'master' }
            steps {
                dir("${CLONE_DIR}") {
                    sh '''
                      cp -f /var/lib/jenkins/workspace/Dockerfile ./Dockerfile
                      cp -f /var/lib/jenkins/workspace/docker-compose.yml ./docker-compose.yml
                      cp -f /var/lib/jenkins/workspace/Jenkinsfile ./Jenkinsfile
                      chown -R jenkins:jenkins .
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            agent { label 'master' }
            steps {
                dir("${CLONE_DIR}") {
                    sh '''
                      sudo docker system prune -af
                      echo ">>> Building Docker image ${REPO}:${TAG}"
                      sudo docker build -t ${REPO}:${TAG} .
                    '''
                }
            }
        }

        stage('Push Docker Image') {
            agent { label 'master' }
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                      echo ">>> Logging in to DockerHub"
                      echo "$DOCKER_PASS" | sudo docker login -u "$DOCKER_USER" --password-stdin

                      echo ">>> Pushing Docker image ${REPO}:${TAG}"
                      sudo docker push ${REPO}:${TAG}

                      sudo docker logout
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    if (params.ENV == 'PROD') {
                        node('PROD-node') {
                            echo ">>> Deploying to PROD"
                            sh """
                                sudo docker rm -f dotnet-hello-world || true
                                sudo docker run -d --restart always --name dotnet-hello-world -p 80:80 ${REPO}:${TAG}
                            """
                        }
                    } else {
                        node('UAT-node') {
                            echo ">>> Deploying to UAT"
                            sh """
                                sudo docker rm -f dotnet-hello-world || true
                                sudo docker run -d --restart always --name dotnet-hello-world -p 80:80 ${REPO}:${TAG}
                            """
                        }
                    }
                }
            }
        }
    }
    post {
        success {
            echo "Build SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
        }
        failure {
            echo "Build FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
        }
    }
}
