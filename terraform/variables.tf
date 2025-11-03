variable "region" {
  type    = string
  default = "europe-north1"
}

variable "service_name" {
  type    = string
  default = "cicd-gha-wif-images-v1"
}

variable "artifact_repo" {
  type    = string
  default = "cicd-gha-wif-images-v1"
}

variable "image_uri" {
  type        = string
  description = "Full image URL including tag or digest, passed from Terraform apply"
}

variable "ingress" {
  type    = string
  default = "INGRESS_TRAFFIC_ALL" # or INGRESS_TRAFFIC_INTERNAL_ONLY
}

variable "allow_unauthenticated" {
  type    = bool
  default = true
}

variable "project_id" {
  type    = string
  default = "hd-github-actions-cicd"
}

variable "service_account_deployer_email" {
  type    = string
  default = "cicd-gha-wif-deployer@hd-github-actions-cicd.iam.gserviceaccount.com"
}

