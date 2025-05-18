#!/bin/bash

# Script to help clean up resources at the end of your project

# Safety check
echo "This script will destroy all resources created in this project."
echo "Are you sure you want to continue? (y/n)"
read confirmation

if [[ $confirmation != "y" && $confirmation != "Y" ]]; then
  echo "Operation cancelled."
  exit 0
fi

# Migrate back to local state if needed
echo "Checking if using remote backend..."
if grep -q 'backend "gcs"' main.tf; then
  echo "Remote backend detected. Migrating back to local backend first..."
  bash migrate_backend.sh local
fi

# Add force_destroy to bucket resource if not already present
if ! grep -q 'force_destroy.*=.*true' main.tf; then
  echo "Adding force_destroy = true to bucket resource..."
  sed -i.bak 's/uniform_bucket_level_access = true/uniform_bucket_level_access = true\n  force_destroy = true/' main.tf
  
  # Apply the change
  echo "Applying configuration to update bucket properties..."
  terraform apply -auto-approve
fi

# Destroy resources
echo "Destroying all resources..."
terraform destroy

if [ $? -eq 0 ]; then
  echo "Cleanup completed successfully!"
else
  echo "Cleanup failed. Please check error messages above."
  exit 1
fi

# Restore main.tf to original state
echo "Restoring main.tf to original state..."
sed -i.bak 's/force_destroy = true/force_destroy = false/' main.tf
rm -f *.bak

echo "Project cleanup completed."
