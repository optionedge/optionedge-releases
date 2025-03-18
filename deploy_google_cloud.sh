#!/bin/bash

echo "🚀 Starting One-Click Deployment on Google Cloud..."

# Ensure gcloud CLI is installed
if ! command -v gcloud &> /dev/null
then
    echo "🔧 Installing gcloud CLI..."
    curl https://sdk.cloud.google.com | bash
    exec -l $SHELL
fi

# Authenticate with Google Cloud (User will be prompted)
echo "🔑 Authenticating with Google Cloud..."
gcloud auth login

# Create a new project (Skip this if using an existing project)
PROJECT_ID="optionedge-$(date +%s)"
gcloud projects create $PROJECT_ID --set-as-default

# Enable required Google Cloud services
echo "✅ Enabling required services..."
gcloud services enable compute.googleapis.com \
    run.googleapis.com \
    cloudbuild.googleapis.com \
    artifactregistry.googleapis.com

# Set project and compute zone
gcloud config set project $PROJECT_ID
gcloud config set compute/zone us-central1-a

# Create a Compute Engine VM for RabbitMQ (Free Tier)
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
    --zone=us-central1-a

# Allow RabbitMQ traffic
echo "🔓 Configuring firewall rules for RabbitMQ..."
gcloud compute firewall-rules create allow-rabbitmq \
    --allow tcp:5672 \
    --target-tags rabbitmq \
    --description "Allow RabbitMQ traffic"

# Get RabbitMQ VM external IP
echo "🌍 Fetching RabbitMQ IP..."
RABBITMQ_IP=$(gcloud compute instances list --filter="name=rabbitmq-vm" --format="value(EXTERNAL_IP)")
echo "RabbitMQ IP: $RABBITMQ_IP"

# Deploy Backend Service on Cloud Run
echo "🚀 Deploying Backend on Cloud Run..."
gcloud builds submit --tag us-central1-docker.pkg.dev/$PROJECT_ID/optionedge-repo/engine:latest
gcloud run deploy optionedge-engine \
    --image=us-central1-docker.pkg.dev/$PROJECT_ID/optionedge-repo/engine:latest \
    --platform=managed \
    --region=us-central1 \
    --allow-unauthenticated \
    --set-env-vars="TZ=Asia/Kolkata,Auth__Domain=https://auth.optionedge.in/oidc,Auth__Audience=https://api.optionedge.in,RuntimeSettings__MessageQueueConnectionString=host=$RABBITMQ_IP:5672;virtualhost=/;username=guest;password=guest;persistentMessages=false"

# Get Backend URL
BACKEND_URL=$(gcloud run services describe optionedge-engine --region=us-central1 --format="value(status.url)")
echo "Backend deployed at: $BACKEND_URL"

# Deploy Frontend Service on Cloud Run
echo "🚀 Deploying Frontend on Cloud Run..."
gcloud builds submit --tag us-central1-docker.pkg.dev/$PROJECT_ID/optionedge-repo/engine-ui:latest
gcloud run deploy optionedge-ui \
    --image=us-central1-docker.pkg.dev/$PROJECT_ID/optionedge-repo/engine-ui:latest \
    --platform=managed \
    --region=us-central1 \
    --allow-unauthenticated \
    --set-env-vars="NUXT_PUBLIC_API_BASE_URL=$BACKEND_URL,NUXT_PUBLIC_AUTH_ENDPOINT=https://auth.optionedge.in,NUXT_PUBLIC_MY_OPTIONEDGE_BASE_URL=https://my.optionedge.in"

# Get Frontend URL
FRONTEND_URL=$(gcloud run services describe optionedge-ui --region=us-central1 --format="value(status.url)")
echo "🌍 Frontend deployed at: $FRONTEND_URL"

echo "✅ Deployment Complete! Access your app at: $FRONTEND_URL"
