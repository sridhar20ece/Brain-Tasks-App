# CI/CD Pipeline for Dockerized Application to AWS EKS

This repository contains the configuration and instructions for a CI/CD pipeline using AWS CodePipeline, CodeBuild, and EKS. The pipeline automates building Docker images, pushing them to ECR, and deploying updates to an EKS cluster.

---

## Pipeline Overview

The CI/CD process consists of three main stages:

### 1. Source

* **Repository:** GitHub
* **Trigger:** Any push to the main branch
* **Action:** CodePipeline fetches the latest code

### 2. Build

* **Service:** AWS CodeBuild
* **Actions:**

  * Build Docker image from the repository
  * Tag the image with a specific version or commit hash
  * Push the Docker image to AWS ECR (Elastic Container Registry)

### 3. Deploy

* **Service:** AWS CodeDeploy (or CodeBuild with kubectl for EKS)
* **Actions:**

  * Update the Kubernetes deployment with the new Docker image
  * Ensure deployment rollout completes successfully
  * Verify pods are running and healthy

---

## Prerequisites

* AWS account with permissions for:

  * EKS
  * ECR
  * CodeBuild
  * CodePipeline
* Existing EKS cluster
* Docker installed on CodeBuild environment
* Kubernetes manifests (Deployment, Service, etc.)

---

## Deployment Instructions

### 1. CodeBuild Role for EKS Access

Ensure your CodeBuild service role has access to your EKS cluster:

```bash
aws eks create-access-entry \
  --cluster-name <EKS_CLUSTER_NAME> \
  --principal-arn <CODEBUILD_ROLE_ARN> \
  --type STANDARD

aws eks associate-access-policy \
  --cluster-name <EKS_CLUSTER_NAME> \
  --principal-arn <CODEBUILD_ROLE_ARN> \
  --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy \
  --access-scope type=cluster
```

### 2. Build and Push Docker Image

Configure your `buildspec.yml` to build and push images:

```yaml
phases:
  build:
    commands:
      - echo "Building Docker image"
      - docker build -t $REPO:$IMAGE_TAG .
      - $(aws ecr get-login --no-include-email --region $AWS_DEFAULT_REGION)
      - docker push $REPO:$IMAGE_TAG
```

### 3. Update EKS Deployment

Use kubectl to update the image in your deployment:

```yaml
post_build:
  commands:
    - kubectl --kubeconfig=/root/.kube/config set image deployment/webapp02 webapp02=$REPO:$IMAGE_TAG
    - kubectl --kubeconfig=/root/.kube/config rollout status deployment/webapp02
```

---

## Verify Deployment

Check deployment status:

```bash
kubectl get deployments -A
kubectl get pods -l app=webapp02
kubectl logs <pod-name>
```

---

## Notes

* Ensure the kubeconfig is configured for CodeBuild.
* Use proper IAM roles and least privilege.
* Monitor build logs in CodeBuild and CloudWatch for troubleshooting.

---

## License

This repository is licensed under the MIT License. See [LICENSE](LICENSE) for details.
# My Update
