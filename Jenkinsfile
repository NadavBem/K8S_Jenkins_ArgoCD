pipeline {
    agent any
    
    environment {
        DOCKERHUB_CREDENTIALS = credentials('DockerHub')
        GIT_CREDENTIALS = credentials('GitHub')
        DOCKER_IMAGE = "nadav0176/my_app"
        VERSION = "${env.BUILD_NUMBER}"
        REPO_URL = 'https://github.com/NadavBem/K8S_Jenkins_ArgoCD.git'
        BRANCH = 'main'
    }
    
    stages {
        stage('Checkout') {
            steps {
                script {
                    def authorName = sh(
                        script: "git log -1 --pretty=format:'%an'",
                        returnStdout: true
                    ).trim()
                    if (authorName == "Jenkins") {
                        currentBuild.result = 'SUCCESS'
                        error "Skipping build due to Jenkins commit"
                    }
                }
                 git branch: "${BRANCH}", url: "${REPO_URL}", credentialsId: "${GIT_CREDENTIALS}"
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${DOCKER_IMAGE}:${VERSION}")
                }
            }
        }
        
        stage('Push to DockerHub') {
            steps {
                script {
                    docker.withRegistry('', 'DockerHub') {
                        dockerImage.push()
                    }
                }
            }
        }

        stage('Update Kubernetes Manifests') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'GitHub', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASSWORD')]) {
                        sh """
                            git config user.name "${GIT_USER}"
                            git config user.email "${GIT_USER}@example.com"
                            sed -i 's|image: ${DOCKER_IMAGE}:.*|image: ${DOCKER_IMAGE}:${VERSION}|' ConfigFiles/cluster_config/deployment.yaml
                            git add ConfigFiles/cluster_config/deployment.yaml
                            git commit -m 'Update image to ${DOCKER_IMAGE}:${VERSION}'
                            git push https://${GIT_USER}:${GIT_PASSWORD}@github.com/NadavBem/K8S_Jenkins_ArgoCD.git main
                        """
                    }
                }
            }
        }
    }
}