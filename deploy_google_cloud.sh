#!/bin/bash

echo "🚀 Starting One-Click Deployment on Google Cloud..."
set -e  # Exit script immediately if any command fails

# Authenticate with Google Cloud (User will be prompted)
gcloud auth login --quiet

# Create a new project (skip if the user already has a project)
PROJECT_ID="optionedge-1742279787"
gcloud projects create $PROJECT_ID --set-as-default
gcloud config set project $PROJECT_ID

# Enable required Google Cloud services
gcloud services enable compute.googleapis.com \
    run.googleapis.com \
    cloudbuild.googleapis.com --quiet  # Removed artifactregistry.googleapis.com

# Set default compute zone to Free Tier region
gcloud config set compute/zone us-central1-a

# Deploy RabbitMQ on Compute Engine (Free Tier)
echo "📦 Deploying RabbitMQ on Compute Engine..."
gcloud compute instances create rabbitmq-vm \
    --machine-type=e2-micro \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --tags=rabbitmq \
    --metadata=startup-script='#!/bin/bash
        sudo apt update
        sudo apt install -y rabbitmq-server
        sudo systemctl enable rabbitmq-server
        sudo systemctl start rabbitmq-server
        sudo rabbitmqctl add_user guest guest
        sudo rabbitmqctl set_user_tags guest administrator
        sudo rabbitmqctl set_permissions -p / guest ".*" ".*" ".*"
    ' \
    --zone=us-central1-a --quiet

# Allow RabbitMQ traffic
gcloud compute firewall-rules create allow-rabbitmq \
    --allow tcp:5672 \
    --target-tags rabbitmq \
    --description "Allow RabbitMQ traffic" --quiet

# Get RabbitMQ VM external IP
RABBITMQ_IP=$(gcloud compute instances list --filter="name=rabbitmq-vm" --format="value(EXTERNAL_IP)")
echo "🐇 RabbitMQ deployed at IP: $RABBITMQ_IP"

# Deploy Backend to Cloud Run (Using Docker Hub Image)
echo "🚀 Deploying Backend..."
gcloud run deploy optionedge-engine \
    --image=docker.io/optionedge/engine:1.0.22 \  # Pull from Docker Hub
    --platform=managed \
    --region=us-central1 \
    --allow-unauthenticated \
    --set-env-vars="TZ=Asia/Kolkata,Auth__Domain=https://auth.optionedge.in/oidc,Auth__Audience=https://api.optionedge.in,RuntimeSettings__MessageQueueConnectionString=host=$RABBITMQ_IP:5672;virtualhost=/;username=guest;password=guest;persistentMessages=false" \
    --max-instances=1 --quiet  # Ensures Cloud Run stays within Free Tier

# Get Backend URL
BACKEND_URL=$(gcloud run services describe optionedge-engine --region=us-central1 --format="value(status.url)")
echo "🌍 Backend deployed at: $BACKEND_URL"

# Deploy Frontend to Cloud Run (Using Docker Hub Image)
echo "🚀 Deploying Frontend..."
gcloud run deploy optionedge-ui \
    --image=docker.io/optionedge/engine_ui:1.0.22 \  # Pull from Docker Hub
    --platform=managed \
    --region=us-central1 \
    --allow-unauthenticated \
    --set-env-vars="NUXT_PUBLIC_API_BASE_URL=$BACKEND_URL,NUXT_PUBLIC_AUTH_ENDPOINT=https://auth.optionedge.in,NUXT_PUBLIC_MY_OPTIONEDGE_BASE_URL=https://my.optionedge.in" \
    --max-instances=1 --quiet  # Prevents extra charges

# Get Frontend URL
FRONTEND_URL=$(gcloud run services describe optionedge-ui --region=us-central1 --format="value(status.url)")
echo "✅ Deployment Complete! Access your app at: $FRONTEND_URL"

# Cleanup: Delete Artifact Registry if it exists (No longer needed)
if gcloud artifacts repositories list --filter="name=optionedge-repo" --format="value(name)" | grep -q "optionedge-repo"; then
    echo "🗑️ Deleting unused Artifact Registry..."
    gcloud artifacts repositories delete optionedge-repo --location=us-central1 --quiet
fi
