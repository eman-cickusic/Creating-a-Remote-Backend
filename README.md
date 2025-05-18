# Creating a Remote Backend

This repository demonstrates how to migrate a Terraform state from a local backend to a Google Cloud Storage (GCS) remote backend. This is a critical skill for production-ready Terraform deployments, enabling team collaboration and secure state management.

## Project Overview

In this project, you will:
1. Create a Terraform configuration with a local backend
2. Set up a Google Cloud Storage bucket for storing state files
3. Migrate the state from the local backend to the GCS backend
4. Modify the infrastructure and observe state updates
5. Clean up resources properly

## Video

https://youtu.be/5aHYp2Dp3c8

## Prerequisites

- Google Cloud Platform account
- Google Cloud SDK installed
- Terraform installed (this project was tested with Terraform v1.x)
- Basic understanding of Terraform and Google Cloud

## Setup Instructions

### 1. Clone this repository

```bash
git clone https://github.com/YOUR-USERNAME/terraform-remote-backend.git
cd terraform-remote-backend
```

### 2. Authentication

Make sure you're authenticated with Google Cloud:

```bash
gcloud auth login
gcloud config set project YOUR-PROJECT-ID
```

### 3. Initialize Terraform with Local Backend

The initial configuration uses a local backend:

```bash
terraform init
```

### 4. Apply Initial Configuration

This creates your GCS bucket while still using a local state file:

```bash
terraform apply
```

You'll see the state file created at `terraform/state/terraform.tfstate`.

### 5. Migrate to Remote Backend

After modifying `main.tf` to use the GCS backend:

```bash
terraform init -migrate-state
```

This command will prompt you to confirm migration of the state to GCS.

### 6. Verify Remote State

You can view your state file in the Google Cloud Console:
- Navigate to Cloud Storage > Buckets
- Click on your bucket
- Browse to `terraform/state/default.tfstate`

## File Structure

```
terraform-remote-backend/
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Variable definitions
├── outputs.tf              # Output definitions
├── versions.tf             # Terraform and provider version constraints
├── terraform/
│   └── state/              # Directory for local state (if using local backend)
└── README.md               # Project documentation
```

## Step-by-Step Walkthrough

### Local Backend Configuration

The initial configuration in `main.tf` includes:

```terraform
provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "test-bucket-for-state" {
  name                        = var.bucket_name
  location                    = "US"
  uniform_bucket_level_access = true
}

terraform {
  backend "local" {
    path = "terraform/state/terraform.tfstate"
  }
}
```

### Remote Backend Configuration

After creating the bucket, we modify the backend configuration:

```terraform
terraform {
  backend "gcs" {
    bucket = "YOUR-BUCKET-NAME"
    prefix = "terraform/state"
  }
}
```

### Testing State Updates

To demonstrate state management, we can add labels to our bucket through the Google Cloud Console and then run:

```bash
terraform refresh
```

This updates the Terraform state to match the real-world infrastructure.

### Cleanup

To properly clean up resources:

1. Migrate back to local state:
```bash
terraform init -migrate-state
```

2. Add `force_destroy = true` to the bucket resource
3. Run `terraform apply`
4. Destroy all resources:
```bash
terraform destroy
```

## Best Practices

1. **State Locking**: GCS backend automatically uses object versioning for state locking
2. **State Encryption**: Consider enabling default encryption on your GCS bucket
3. **Access Control**: Restrict access to your state bucket using IAM policies
4. **State Backup**: Enable versioning on your GCS bucket for state file history

## Troubleshooting

- **Migration Failures**: If state migration fails, check access permissions to the GCS bucket
- **State Conflicts**: When working in teams, ensure everyone has the latest state before making changes
- **Backend Configuration**: Ensure your backend configuration uses the correct bucket name and prefix

## License

This project is licensed under the MIT License - see the LICENSE file for details.
