#!/bin/bash

# This script helps you migrate from local to remote backend and back

# Ensure your variables are set
if [ -z "$1" ]; then
  echo "Usage: ./migrate_backend.sh [local|gcs]"
  exit 1
fi

PROJECT_ID=$(gcloud config get-value project)
BUCKET_NAME="${PROJECT_ID}"

# Function to update the main.tf file
update_backend() {
  local backend_type=$1
  
  if [ "$backend_type" == "local" ]; then
    # Update to local backend
    sed -i.bak '/backend "gcs"/,/}/d' main.tf
    cat << EOF >> main.tf

terraform {
  backend "local" {
    path = "terraform/state/terraform.tfstate"
  }
}
EOF
    echo "Updated main.tf to use local backend"
  elif [ "$backend_type" == "gcs" ]; then
    # Update to GCS backend
    sed -i.bak '/backend "local"/,/}/d' main.tf
    cat << EOF >> main.tf

terraform {
  backend "gcs" {
    bucket = "$BUCKET_NAME"
    prefix = "terraform/state"
  }
}
EOF
    echo "Updated main.tf to use GCS backend with bucket $BUCKET_NAME"
  else
    echo "Invalid backend type: $backend_type"
    exit 1
  fi
}

# Migrate the state
migrate_state() {
  local backend_type=$1
  
  # Initialize with the new backend and migrate state
  echo "Migrating state to $backend_type backend..."
  terraform init -migrate-state -force-copy
  
  if [ $? -eq 0 ]; then
    echo "Successfully migrated state to $backend_type backend"
  else
    echo "Failed to migrate state to $backend_type backend"
    exit 1
  fi
}

# Main logic
case "$1" in
  local)
    update_backend "local"
    migrate_state "local"
    ;;
  gcs)
    update_backend "gcs"
    migrate_state "gcs"
    ;;
  *)
    echo "Invalid option: $1. Use 'local' or 'gcs'"
    exit 1
    ;;
esac

echo "Migration completed successfully!"
