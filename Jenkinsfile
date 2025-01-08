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

        stage('Install kubectl and Azure CLI') {
            steps {
                script {
                    sh """
                    echo "Installing Azure CLI..."
                    curl -sL https://aka.ms/InstallAzureCLIDeb | bash

                    echo "Installing kubectl..."
                    az aks install-cli
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
                    az aks get-credentials --resource-group ${RESOURCE_GROUP} --name ${AKS_CLUSTER}
                    kubectl get nodes
                    """
                }
            }
        }

        stage('Deploy to AKS') {
            steps {
                script {
                    sh """
                    kubectl apply -f ${DEPLOYMENT_FILE}
                    kubectl apply -f ${SERVICE_FILE}
                    kubectl apply -f ${INGRESS_FILE}
                    """
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    sh """
                    kubectl get pods
                    kubectl get svc
                    kubectl get ingress
                    """
                }
            }
        }

        stage('Clean up CLI tools') {
            steps {
                script {
                    sh """
                    echo "Cleaning up Azure CLI and kubectl..."
                    apt-get remove --purge -y azure-cli
                    apt-get remove --purge -y kubectl
                    apt-get autoremove -y
                    """
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution completed.'
        }
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Pipeline failed. Please check the logs.'
        }
    }
}
