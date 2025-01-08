pipeline {
    agent any

    environment {
        IMAGE_NAME = "react-my-hello-world:latest"
        DOCKER_HUB_REPO = "annsvalorem/react-my-hello-world" // Replace with your Docker Hub repository
        DEPLOYMENT_FILE = "deployment.yaml"
        SERVICE_FILE = "service.yaml"
        INGRESS_FILE = "ingress.yaml"
        RESOURCE_GROUP = "TesterRG"    // Replace with your resource group
        AKS_CLUSTER = "AKS1-Tester"   // Replace with your AKS cluster name
    }

    stages {

        stage('Install sudo') {
            steps {
                script {
                    sh """
                    echo "Checking if sudo is installed..."
                    if ! command -v sudo &> /dev/null; then
                        echo "sudo not found, installing it..."
                        apt-get update && apt-get install -y sudo
                    else
                        echo "sudo is already installed."
                    fi
                    """
                }
            }
        }

        stage('Install kubectl and Azure CLI') {
            steps {
                script {
                    sh """
                    echo "Installing Azure CLI..."
                    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

                    echo "Installing kubectl..."
                    sudo az aks install-cli
                    kubectl version --client
                    az version
                    """
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                    docker build -t ${DOCKER_HUB_REPO}:${env.BUILD_NUMBER} .
                    docker tag ${DOCKER_HUB_REPO}:${env.BUILD_NUMBER} ${DOCKER_HUB_REPO}:latest
                    """
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    script {
                        sh """
                        echo ${PASSWORD} | docker login -u ${USERNAME} --password-stdin
                        docker push ${DOCKER_HUB_REPO}:${env.BUILD_NUMBER}
                        docker push ${DOCKER_HUB_REPO}:latest
                        """
                    }
                }
            }
        }

        stage('Configure kubectl for AKS') {
            steps {
                script {
                    sh """
                 
