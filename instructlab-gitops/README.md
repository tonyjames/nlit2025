# InstructLab on OpenShift AI GitOps

This repository contains the GitOps configuration for deploying and managing InstructLab on Red Hat OpenShift AI (or Open Data Hub) with external model serving.

## Structure
```
instructlab-gitops/
├── operators/               # Operator configurations
├── base/                    # Base configurations
├── overlays/                # Environment-specific overlays
└── argocd/                  # ArgoCD applications
```

## Prerequisites

This configuration assumes you have:
1. External Teacher model accessible via HTTP/HTTPS
2. External Judge model accessible via HTTP/HTTPS
3. The connection details for these models stored in secrets

## Installation

1. Install the OpenShift GitOps operator from the OperatorHub

2. Deploy the operators using the app-of-apps pattern:

```
oc apply -f argocd/app-of-apps.yaml
```
3. Once operators are installed, deploy the InstructLab pipeline:
```
oc apply -f argocd/instructlab-pipeline-app.yaml
```
## Running the Pipeline

The pipeline is configured through the OpenShift AI dashboard. Use the parameters defined in the configmap for default values.

## Customizing for Your Environment

1. Update the repository URL in all ArgoCD application files (make update-repos $REPOURL)
2. Update the external model URLs in the teacher-secret.yaml and judge-secret.yaml files
3. Customize storage configurations for your environment

## Secrets Management

For production, encrypt the secret values using either:
- SealedSecrets (bitnami)
- SOPS encryption

## Environment-Specific Configurations

- Development: overlays/dev/
- Production: overlays/prod/
