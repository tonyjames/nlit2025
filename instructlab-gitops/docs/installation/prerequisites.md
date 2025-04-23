# InstructLab Prerequisites

Before installing InstructLab, ensure your environment meets the following prerequisites.

## Infrastructure Requirements

### Minimum Cluster Specifications (PLACEHOLDER UNTIL FURTHER TESTING)

| Component | Minimum Requirement | Recommended |
|-----------|---------------------|-------------|
| OpenShift | 4.12+ | 4.13+ |
| Nodes     | 3 worker nodes | 5+ worker nodes |
| CPU       | 32 cores total | 64+ cores total |
| Memory    | 128 GB total | 256+ GB total |
| Storage   | 500 GB available | 1+ TB available |
| GPU       | 1x NVIDIA A10/A100 | 4+ NVIDIA A100 |

### External Dependencies

1. **External Model Access**
   - Teacher model API endpoint
   - Judge model API endpoint
   - API authentication credentials

2. **Storage**
   - S3-compatible object storage
   - Storage access credentials
   - OCI-compatible registry for model storage

3. **Network Requirements**
   - Outbound internet access (for non-air-gapped installations)
   - DNS resolution for external services
   - Firewall rules allowing required connectivity

## Software Prerequisites

1. **Required Operators**
   - OpenShift GitOps Operator
   - OpenShift Pipelines Operator

2. **CLI Tools**
   - `oc` - OpenShift CLI
   - `kustomize` - Kustomize CLI
   - `argocd` - Argo CD CLI

## Namespace Setup

1. **Core Namespaces**
   - `openshift-gitops` - GitOps operator namespace
   - `data-science-project` - Default namespace for InstructLab components

## Authentication and Authorization

1. **Cluster Admin Access**
   - Required for initial setup
   - Required for operator installation

2. **Project Permissions**
   - Edit access to `data-science-project` namespace