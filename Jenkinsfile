pipeline {
    agent any
    
    environment {
        DOCKERHUB_CREDENTIALS = credentials('DockerHub')
        GIT_CREDENTIALS = credentials('GitHub')
        DOCKER_IMAGE = "nadav0176/my_app"
        VERSION = "${env.BUILD_NUMBER}"
        REPO_URL = 'https://github.com/NadavBem/K8S_Jenkins_ArgoCD'
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
        
        //  stage('Update Kubernetes Manifests') {
        //     steps {
        //         script {
        //             sh """
        //                 sed -i 's|image: ${DOCKER_IMAGE}:.*|image: ${DOCKER_IMAGE}:${VERSION}|' ConfigFiles/cluster_config/deployment.yaml
        //             """
        //             withCredentials([usernamePassword(credentialsId: 'github_cred', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
        //                 sh '''
        //                     git config --global user.email "jenkins@example.com"
        //                     git config --global user.name "Jenkins"
        //                     git add .
        //                     git commit -m "Update deployment.yaml with build number ${BUILD_NUMBER}"
        //                     git push https://${USERNAME}:${PASSWORD}@github.com/DorAvissar/K8S_Jenkins.git main
        //                 '''
        //             }

        //             echo 'Finished pushing changes to GitHub'

        //         }
        //     }
        // }
    }
}