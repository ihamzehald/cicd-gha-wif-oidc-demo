#!/bin/bash
set -e

# =====================================
# GCP Bootstrap Script
# -------------------------------------
# Runs once to prepare a GCP project for GitHub Actions deployment:
# 1. Enables required GCP APIs
# 2. Creates a GHA deployer Service Account
# 3. Grants required IAM roles
# 4. Creates an Artifact Registry for Docker images
# 5. Creates a GCS bucket for Terraform state
# 6. Configures Workload Identity Federation (WIF)
# =====================================

# =====================================
# ENV CONFIGURATION
# =====================================
SCRIPT_VERSION="v1" # Used in case you have multiple setups in the same project
PROJECT_ID="gha-cicd" # Replace with your GCP Project ID
PROJECT_NUMBER="123456789012" # Replace with your GCP Project Number
REGION="europe-north1"
ARTIFACT_REPO="cicd-gha-wif-images-${SCRIPT_VERSION}"
SERVICE_ACCOUNT_NAME="cicd-gha-wif-deployer-${SCRIPT_VERSION}"
BUCKET_NAME="cicd-gha-wif-tfstate-${SCRIPT_VERSION}"
IMAGE_NAME="cicd-gha-wif-image-${SCRIPT_VERSION}"
SERVICE_NAME="cicd-gha-wif-service-${SCRIPT_VERSION}"
WIF_POOL_NAME="gha-pool-wif-${SCRIPT_VERSION}"
WIF_PROVIDER_NAME="gha-wif-provider-${SCRIPT_VERSION}"
ORG="ihamzehald"
REPO="cicd-gha-wif-oidc-demo"
# =====================================

echo "Activating project..."
gcloud config set project "${PROJECT_ID}"

echo "Enabling required APIs..."
gcloud services enable \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com \
  run.googleapis.com \
  iam.googleapis.com \
  iamcredentials.googleapis.com \
  serviceusage.googleapis.com \
  storage.googleapis.com \
  cloudresourcemanager.googleapis.com

SA_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# =====================================
# SERVICE ACCOUNT CREATION
# =====================================
echo "Creating service account..."
gcloud iam service-accounts create "$SERVICE_ACCOUNT_NAME" \
  --display-name="GitHub Actions Deployer" || echo "Service account may already exist"

echo "Granting IAM roles to service account..."
for ROLE in roles/run.admin roles/artifactregistry.admin roles/iam.serviceAccountUser roles/storage.admin roles/iam.workloadIdentityPoolAdmin; do
  gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="$ROLE" || true
done

# =====================================
# ARTIFACT REGISTRY
# =====================================
echo "Creating Artifact Registry repository (if not exists)..."
gcloud artifacts repositories create "${ARTIFACT_REPO}" \
  --repository-format=docker \
  --location="${REGION}" \
  --description="Docker images for Cloud Run" \
  --project="${PROJECT_ID}" || echo "Repository already exists."

# =====================================
# TERRAFORM STATE BUCKET
# =====================================
echo "Creating Terraform state bucket..."
gcloud storage buckets create gs://${BUCKET_NAME} \
  --project=${PROJECT_ID} \
  --location=${REGION} \
  --uniform-bucket-level-access || echo "Bucket already exists."
gcloud storage buckets update gs://${BUCKET_NAME} --versioning || true

# =====================================
# WORKLOAD IDENTITY FEDERATION (WIF)
# =====================================
echo "Creating Workload Identity Pool..."
gcloud iam workload-identity-pools create "${WIF_POOL_NAME}" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --display-name="GitHub Actions Pool" || echo "Pool may already exist"

echo "Creating OIDC provider for GitHub Actions..."
gcloud iam workload-identity-pools providers create-oidc "${WIF_PROVIDER_NAME}" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --workload-identity-pool="${WIF_POOL_NAME}" \
  --display-name="GitHub Actions provider (new)" \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.ref=assertion.ref,attribute.repository_owner=assertion.repository_owner" \
  --attribute-condition="attribute.repository_owner=='${ORG}'" || echo "Provider may already exist"

PROVIDER_NAME="projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${WIF_POOL_NAME}/providers/${WIF_PROVIDER_NAME}"

echo "Granting Workload Identity User role..."
gcloud iam service-accounts add-iam-policy-binding "${SA_EMAIL}" \
  --project="${PROJECT_ID}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${WIF_POOL_NAME}/attribute.repository/${ORG}/${REPO}" \
  || echo "IAM binding may already exist"

# =====================================
# DONE
# =====================================
echo "============================================"
echo "✅ GCP bootstrap complete!"
echo "Set these variables in your GitHub repository → Settings → Secrets and variables → Actions:"
echo "  PROJECT_ID = ${PROJECT_ID}"
echo "  REGION = ${REGION}"
echo "  ARTIFACT_REPO = ${ARTIFACT_REPO}"
echo "  IMAGE_NAME = ${IMAGE_NAME}"
echo "  SERVICE_NAME = ${SERVICE_NAME}"
echo "  WIF_PROVIDER = projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${WIF_POOL_NAME}/providers/${WIF_PROVIDER_NAME}"
echo "  WIF_SERVICE_ACCOUNT = ${SA_EMAIL}"
echo "============================================"
