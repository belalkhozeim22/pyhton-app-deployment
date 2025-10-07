pipeline {
  agent any

  parameters {
    string(name: 'PROJECT_ID', defaultValue: 'theta-ember-474415-r8', description: 'GCP Project ID')
    string(name: 'ZONE', defaultValue: 'us-central1-a', description: 'GCP zone us-central1-a')
    string(name: 'CLUSTER_NAME', defaultValue: 'microservice-gke', description: 'GKE cluster name')
  }

  environment {
    IMAGE_NAME = "python-microservice"
    KUBE_NAMESPACE = "microservice"
    KUBE_DEPLOYMENT = "python-microservice"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Authenticate & Build & Push Image') {
      steps {
        withCredentials([file(credentialsId: 'gcp-service-account-json', variable: 'GCLOUD_KEY')]) {
          sh '''
            set -e
            echo "Authenticating with GCP..."
            gcloud auth activate-service-account --key-file=${GCLOUD_KEY}
            gcloud config set project ${PROJECT_ID}
            gcloud auth configure-docker --quiet

            echo "Building Docker image..."
            docker build -t ${IMAGE_NAME}:latest .

            GCR_IMAGE=gcr.io/${PROJECT_ID}/${IMAGE_NAME}:${BUILD_NUMBER}
            echo "Tagging and pushing as ${GCR_IMAGE}"
            docker tag ${IMAGE_NAME}:latest ${GCR_IMAGE}
            docker push ${GCR_IMAGE}

            # persist image name for later stage
            echo ${GCR_IMAGE} > image-url.txt
          '''
        }
      }
    }

    stage('Deploy to GKE') {
      steps {
        withCredentials([file(credentialsId: 'gcp-service-account-json', variable: 'GCLOUD_KEY')]) {
          sh '''
            set -e
            echo "Authenticating again for deployment..."
            gcloud auth activate-service-account --key-file=${GCLOUD_KEY}
            gcloud config set project ${PROJECT_ID}

            echo "Fetching GKE credentials..."
            gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${ZONE} --project ${PROJECT_ID}


            kubectl apply -f infrastructure/k8s/namespace.yaml
            kubectl apply -f infrastructure/k8s/deployment.yaml
            kubectl apply -f infrastructure/k8s/service.yaml
          '''
        }
      }
    }
  }

  post {
        success {
            script {
                def image = readFile('image-url.txt').trim()
                echo "Build & deploy succeeded. Image: ${image}"
            }
        }
        failure {
            mail to: 'belalkhozeim22@gmail.com',
                 subject: "Build failed: ${env.JOB_NAME} ${env.BUILD_NUMBER}",
                 body: "Check the Jenkins console output"
        }
    }
}
