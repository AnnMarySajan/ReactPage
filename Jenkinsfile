pipeline {
    agent any

    environment {
        IMAGE_NAME = "react-my-hello-world:latest"
        DOCKER_HUB_REPO = "annsvalorem/react-my-hello-world" // Replace with your Docker Hub repository
        DEPLOYMENT_FILE = "deployment.yaml"
        SERVICE_FILE = "service.yaml"
        INGRESS_FILE = "ingress.yaml"
        RESOURCE_GROUP = "TestRG"    // Replace with your resource group
        AKS_CLUSTER = "AKS1-Test"          // Replace with your AKS cluster name
    }

    stages {
        stage('Clone Repository') {
            steps {
                // Checkout the repository with the Dockerfile and YAML files
                git url: 'https://github.com/annmselizabeth/ReactPage.git' // Replace with your repo details
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
                withCredentials([string(credentialsId: 'docker-hub-token', variable: 'DOCKER_HUB_TOKEN')]) {
                    script {
                        sh """
                        echo ${DOCKER_HUB_TOKEN} | docker login -u your-dockerhub-username --password-stdin
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
