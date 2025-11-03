# cicd-gha-wif-oidc-demo

CI/CD GitHub Actions using GCP Workload Identity Federation (OIDC)

# Setup Steps

The current CI/CD pipeline in this repository is failing — and that’s expected, since it is not yet configured for a GCP project.  
To make the CI/CD pipeline pass, clone the project and push it to your own GitHub account (make the repo private),  
then do follow the steps below.

**Step #1:** Configure your GCP project and link it to a billing account.

**Step #2:** In your terminal, navigate to the project root folder and edit the environment variables in `bootstrap.sh` script as needed, then run the bootstrap script (`./bootstrap.sh`).  
This script will execute the necessary `gcloud` commands to set up your GCP project with your GitHub Actions workflow.  
It will do the following:

 1. Enables required GCP APIs.

 2. Creates a GHA deployer Service Account.

 3. Grants required IAM roles.

 4. Creates an Artifact Registry for Docker images.

 5. Creates a GCS bucket for Terraform state.

 6. Configures Workload Identity Federation (WIF).

 P.S. This script can be terraformed if needed (in case of full automation and scalability) but as it is a bootstrap one time script this is a common practice as per GCP guidelines and considering TF needs these configs in place as prerequisites before it can run.

**Step #3:** Finally follow the instructions displayed on your terminal after it completes execution to configure your repository with the GCP project.  
Once you’ve configured the repo environment variables as described, commit and push to `master` branch to verify that the CI/CD pipeline builds successfully.
