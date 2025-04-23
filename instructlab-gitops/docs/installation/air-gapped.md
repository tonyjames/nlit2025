# Air-Gapped Installation Guide

This guide provides instructions for installing InstructLab on OpenShift in an air-gapped environments.

## Air-Gapped Installation Overview

Air-gapped installations require additional preparation to ensure all required resources are available locally:

1. Required container images must be mirrored to a local registry
2. Required operators must be available in the disconnected catalog
3. Git taxonomy repositories must be accessible within the air-gapped environment

## Prerequisites for Air-Gapped Installation

- Local container registry with sufficient storage
- Disconnected catalog source for OpenShift operators
- Internal Git server for hosting the GitOps repository
- Access to mirror container images from an internet-connected system

## Preparation Steps

### 1. Mirror Required Images

On an internet-connected system with access to the local registry:

```bash
# Create a list of required images
cat > images-list.txt << EOF
registry.redhat.io/openshift-gitops-1/argocd-rhel8:v1.5.1
registry.redhat.io/rhelai1/instructlab-nvidia-rhel9:latest
quay.io/modh/odh-generic-data-science-notebook:v2-latest
quay.io/modh/odh-pipeline-rest-server:v2-latest
quay.io/modh/vllm:latest
EOF

# Mirror images to internal registry
oc image mirror -f images-list.txt --insecure=true --registry-config=./registry-config.json
```

### 2. Configure ImageContentSourcePolicy

Apply the included ImageContentSourcePolicy:

```bash
oc apply -f instructlab-gitops/operators/base/disconnected/imagecontentsourcepolicy.yaml
```

### 3. Configure Disconnected Catalog Sources

Ensure the required operator catalogs are available:

```bash
oc apply -f - << EOF
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: redhat-operators-disconnected
  namespace: openshift-marketplace
spec:
  sourceType: grpc
  image: internal-registry.example.com/olm/redhat-operators:v4.13
  displayName: Red Hat Operators Disconnected
  publisher: Red Hat
EOF
```

### 4. Configure Internal Git Repository

Clone the repository to your internal Git server:

```bash
git clone --mirror https://github.com/open-demos/nlit2025.git
git push --mirror https://internal-git.example.com/nlit2025.git
```

## Installation Steps

### 1. Update Repository URLs

Update all Argo CD application definitions to use your internal Git server:

```bash
make update-repos REPO_URL=https://internal-git.example.com/nlit2025.git
```

### 2. Deploy the Air-Gapped Stack

Deploy the operators with the disconnected configuration:

```bash
# Enable the disconnected configuration to resolve public registry names
sed -i 's/# - disconnected/- disconnected/' instructlab-gitops/operators/base/kustomization.yaml

# Apply the operators
make apply-operators ENV=prod
```

Deploy the pipeline:

```bash
make apply-pipeline ENV=prod
```

## Troubleshooting Air-Gapped Installations

Common issues in air-gapped environments include:

1. **Missing Images** - Check if all required images are mirrored
2. **Catalog Source Issues** - Verify catalog sources are correctly configured
3. **Git Repository Access** - Ensure Argo CD can access the internal Git server
4. **Pull Secret Configuration** - Verify pull secrets for the internal registry

Check the Argo CD logs for issues:

```bash
oc logs deployment/openshift-gitops-server -n openshift-gitops
```

## Maintaining an Air-Gapped Installation

1. **Regular Updates** - Mirror new images as they become available
2. **Catalog Updates** - Update disconnected catalogs regularly
3. **Security Patches** - Ensure security patches are applied promptly