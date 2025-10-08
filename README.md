# =========================================================
# 🚀 Python Microservice Deployment on GKE with Jenkins CI/CD
# =========================================================
## Overview
This repository contains:
- Dockerfile for the Python microservice
- Terraform code to provision a GKE cluster and a CI service account
- Kubernetes manifests to deploy the microservice and expose it via LoadBalancer
- Jenkinsfile to build, push to Google Container Registry (GCR), and deploy
- Monitoring instructions (Prometheus + Grafana)

## Requirements (locally)
- Git
- Docker 
- Google Cloud SDK 
- Helm
- kubectl
- Terraform 
- Jenkins 


# --- 1️⃣ Clone the Repository ---
git clone https://github.com/sameh-Tawfiq/Microservices.git
cd Microservices

# --- 2️⃣ Dockerize and Test Application ---
docker build -t python-microservice .
docker run -d -p 8080:5000 python-microservice

# --- 3️⃣ Authenticate and Configure GCP ---
gcloud auth application-default login
gcloud config set project 

# --- 4️⃣ Provision GKE Cluster with Terraform ---
cd infra/terraform
terraform init
terraform apply -auto-approve
gcloud container clusters get-credentials microservice-gke --zone  --project 

# --- 5️⃣ Deploy Microservice to Kubernetes ---
cd ../k8s
kubectl apply -f namespace.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

echo "✅ Check deployment status"
kubectl get pods -n microservice
kubectl get svc -n microservice
echo "🌍 Access app at: http://<EXTERNAL-IP>:8080"

# --- 6️⃣ Install Jenkins on a GCE VM ---
sudo apt update -y
sudo apt install -y openjdk-17-jdk apt-transport-https ca-certificates gnupg
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/ | \
sudo tee /etc/apt/sources.list.d/jenkins.list
sudo apt update -y
sudo apt install -y jenkins docker.io
sudo systemctl enable --now jenkins

# --- 7️⃣ Open Jenkins Port in GCP ---
gcloud compute firewall-rules create allow-jenkins \
  --allow tcp:8080 \
  --target-tags=jenkins-server \
  --source-ranges=0.0.0.0/0

# --- 8️⃣ Get Jenkins Initial Password ---
echo "🔑 Jenkins admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo "Access Jenkins at: http://EXTERNAL_IP:8080"

# --- 9️⃣ Jenkins Configuration (Manual Steps) ---
echo "⚙️  In Jenkins UI:"
echo "1️⃣ Install plugins: Pipeline, Docker Pipeline, Credentials Binding"
echo "2️⃣ Add GCP JSON credential: ID = gcp-service-account-json"
echo "3️⃣ Create a Pipeline job using this repo with Jenkinsfile"
echo "4️⃣ Run the pipeline to build → push → deploy automatically"

# --- 🔟 Verify Deployment ---
kubectl get pods -A
kubectl get svc -A

echo " Deployment Completed Successfully!"
echo "App running on: http://LOADBALANCER_EXTERNAL_IP:8080"


