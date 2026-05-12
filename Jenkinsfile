pipeline {
    agent any

    environment {
        // FIXME: Hãy thay đổi 'yourdockerhubusername' bằng tên đăng nhập Docker Hub thật của bạn!
        DOCKER_HUB_USER = 'minhtri25' 
        IMAGE_NAME = 'react-realworld-devops'
        REGISTRY_CREDENTIALS_ID = 'docker-hub-credentials'
    }

    stages {
        stage('Checkout') {
            steps {
                // Tự động kéo mã nguồn từ git
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                // Chạy npm install bằng container Node 16 tạm thời để không cần cài Node vào Jenkins
                sh 'docker run --rm -v ${WORKSPACE}:/app -w /app node:16-alpine npm install --legacy-peer-deps'
            }
        }

        stage('Test') {
            steps {
                // Chạy test một lần duy nhất (CI=true)
                sh 'docker run --rm -v ${WORKSPACE}:/app -w /app node:16-alpine sh -c "CI=true npm test"'
            }
        }

        stage('Build Production') {
            steps {
                // Biên dịch mã nguồn React tối ưu cho Production
                sh 'docker run --rm -v ${WORKSPACE}:/app -w /app node:16-alpine npm run build'
            }
        }

        stage('Docker Build Image') {
            steps {
                // Tiến hành đóng gói ứng dụng thành Docker Image
                sh "docker build -t ${DOCKER_HUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER} -t ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest ."
            }
        }

        stage('Docker Push to Hub') {
            steps {
                // Đăng nhập Docker Hub bằng Credentials của Jenkins và đẩy Image lên
                withCredentials([usernamePassword(credentialsId: "${REGISTRY_CREDENTIALS_ID}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                    sh "docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER}"
                    sh "docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest"
                }
            }
        }

        stage('Deploy Locally') {
            steps {
                script {
                    // Dừng container cũ nếu có trên máy host WSL và khởi chạy container mới từ image vừa build
                    sh "docker stop ${IMAGE_NAME}-prod || true"
                    sh "docker rm ${IMAGE_NAME}-prod || true"
                    sh "docker run -d -p 4100:4100 --name ${IMAGE_NAME}-prod ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest"
                }
            }
        }
    }
}
