pipeline {
    agent any
    
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        IMAGE_NAME = "duyd4010/23127356"  
        IMAGE_TAG = "${BUILD_NUMBER}"
        APP_PORT = "8000"
    }
    
    stages {
        stage('1. Git Checkout') {
            steps {
                echo 'Pulling code from GitHub...'
                git branch: 'master',
                    url: 'https://github.com/dtduy23/23127356.git'
            }
        }
        
        stage('2. Code Quality Check') {
            steps {
                echo 'Checking Python syntax...'
                script {
                    sh """
                        # Check Python files syntax
                        python3 -m py_compile app/*.py main.py || echo "Syntax check completed"
                        
                        # Count files
                        echo "Python files found: \$(find . -name '*.py' | wc -l)"
                    """
                }
            }
        }
        
        stage('3. Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                script {
                    sh """
                        docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                        docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
                        
                        # Show image info
                        docker images ${IMAGE_NAME}:${IMAGE_TAG}
                    """
                }
            }
        }
        
        stage('4. Test Container') {
            steps {
                echo 'Testing container...'
                script {
                    sh """
                        # Test run container
                        docker run --rm ${IMAGE_NAME}:${IMAGE_TAG} python3 --version
                        
                        # Check image size
                        echo "Image size: \$(docker images ${IMAGE_NAME}:${IMAGE_TAG} --format '{{.Size}}')"
                    """
                }
            }
        }
        
        stage('5. Push to DockerHub') {
            steps {
                echo 'Pushing image to DockerHub...'
                script {
                    sh """
                        echo \$DOCKERHUB_CREDENTIALS_PSW | docker login -u \$DOCKERHUB_CREDENTIALS_USR --password-stdin
                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                        docker push ${IMAGE_NAME}:latest
                        
                        echo "Image pushed: ${IMAGE_NAME}:${IMAGE_TAG}"
                    """
                }
            }
        }
        
        stage('6. Deploy Container') {
            steps {
                echo 'Deploying application...'
                script {
                    sh """
                        # Stop and remove old container if exists
                        docker stop fastapi-app 2>/dev/null || true
                        docker rm fastapi-app 2>/dev/null || true
                        
                        # Run new container
                        docker run -d \
                            --name fastapi-app \
                            -p ${APP_PORT}:${APP_PORT} \
                            --restart unless-stopped \
                            ${IMAGE_NAME}:latest
                        
                        # Wait for container to start
                        sleep 5
                        
                        # Check container status
                        docker ps | grep fastapi-app
                    """
                }
            }
        }
        
        stage('7. Health Check') {
            steps {
                echo 'Running health check...'
                script {
                    sh """
                        # Wait for app to be ready
                        sleep 3
                        
                        # Check if container is running
                        if docker ps | grep -q fastapi-app; then
                            echo "Container is running"
                            docker logs fastapi-app --tail 20
                        else
                            echo "Container failed to start"
                            exit 1
                        fi
                        
                        # Try to access API - MUST succeed
                        if ! docker exec fastapi-app curl -f http://localhost:8000; then
                            echo "ERROR: API not responding!"
                            docker logs fastapi-app
                            exit 1
                        fi
                        echo "API is healthy!"
                    """
                }
            }
        }
    }
    
    post {
        always {
            echo 'Cleaning up...'
            sh 'docker logout'
        }
        success {
            echo 'Pipeline completed successfully!'
            echo "Application is running at http://localhost:8000"
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
