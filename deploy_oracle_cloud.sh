#!/bin/bash

echo "🚀 Checking Oracle Cloud Setup..."

# ✅ Auto-fetch COMPARTMENT_ID (User's Default)
COMPARTMENT_ID=$(oci iam compartment list --query 'data[0]."id"' --raw-output)
echo "✅ Using Compartment: $COMPARTMENT_ID"

# ✅ Check if VCN exists, create if not
VCN_ID=$(oci network vcn list --compartment-id $COMPARTMENT_ID --query 'data[0]."id"' --raw-output)
if [ -z "$VCN_ID" ]; then
  echo "🔹 Creating Virtual Cloud Network (VCN)..."
  VCN_ID=$(oci network vcn create --compartment-id $COMPARTMENT_ID --cidr-block "10.0.0.0/16" --display-name "OptionEdgeVCN" --query "data.id" --raw-output)
  echo "✅ VCN Created: $VCN_ID"
fi

# ✅ Check if Subnet exists, create if not
SUBNET_ID=$(oci network subnet list --compartment-id $COMPARTMENT_ID --query 'data[0]."id"' --raw-output)
if [ -z "$SUBNET_ID" ]; then
  echo "🔹 Creating Subnet..."
  SUBNET_ID=$(oci network subnet create --compartment-id $COMPARTMENT_ID --vcn-id $VCN_ID --cidr-block "10.0.1.0/24" --display-name "OptionEdgeSubnet" --query "data.id" --raw-output)
  echo "✅ Subnet Created: $SUBNET_ID"
fi

# ✅ Auto-fetch latest Ampere A1 Image ID
IMAGE_ID=$(oci compute image list \
  --compartment-id $COMPARTMENT_ID \
  --operating-system "Oracle Linux" \
  --operating-system-version "8" \
  --shape "VM.Standard.A1.Flex" \
  --query 'data[0]."id"' --raw-output)
echo "✅ Using Image ID: $IMAGE_ID"

INSTANCE_NAME="optionedge-arm-instance"
SHAPE="VM.Standard.A1.Flex"

echo "🚀 Creating Oracle Cloud VM for OptionEdge on ARM..."

# Step 1: Create Oracle VM (Fully Automated)
INSTANCE_ID=$(oci compute instance launch \
  --availability-domain "1" \
  --compartment-id $COMPARTMENT_ID \
  --image-id $IMAGE_ID \
  --shape $SHAPE \
  --shape-config '{"ocpus": 4, "memoryInGBs": 24}' \
  --subnet-id $SUBNET_ID \
  --assign-public-ip true \
  --display-name $INSTANCE_NAME \
  --wait-for-state RUNNING \
  --query "data.id" --raw-output)

echo "✅ Instance $INSTANCE_NAME created successfully!"

# Get Public IP of the instance
PUBLIC_IP=$(oci compute instance list-vnics --instance-id $INSTANCE_ID --query "data[0].\"public-ip\"" --raw-output)
echo "🌍 Public IP: $PUBLIC_IP"

# Step 2: SSH into the VM and Install Docker
ssh -o StrictHostKeyChecking=no opc@$PUBLIC_IP << 'EOF'
  echo "🔹 Installing Docker & Docker Compose..."
  sudo dnf update -y
  sudo dnf install -y docker
  sudo systemctl start docker
  sudo systemctl enable docker
  sudo usermod -aG docker $USER

  # Step 3: Pull & Run OptionEdge Docker Containers
  echo "🚀 Pulling OptionEdge Docker Containers..."
  docker pull optionedge/engine_ui:latest
  docker pull optionedge/engine:latest

  echo "🚀 Starting Docker Containers..."
  docker run -d -p 3000:3000 --name engine_ui optionedge/engine_ui:latest
  docker run -d -p 8080:8080 --name engine optionedge/engine:latest

  echo "✅ Deployment complete!"
EOF

echo "🌍 Access the app at: http://$PUBLIC_IP:3000"
