# Getting Started with InstructLab

This guide provides a quick start for deploying InstructLab on OpenShift AI.

## Quick Installation

### 1. Install Prerequisites

Ensure you have the OpenShift GitOps operator installed:

```bash
oc apply -f https://raw.githubusercontent.com/open-demos/nlit2025/main/operator-configs/gitops-operator.yaml
```

Wait for the operator to be ready:

```bash
oc wait --for=condition=Available deployment/openshift-gitops-operator-controller-manager -n openshift-operators --timeout=300s
```

### 2. Clone the Repository

```bash
git clone https://github.com/open-demos/nlit2025.git
cd nlit2025
```

### 3. Update Repository URL (Optional)

If you're using your own fork, update the repository URLs:

```bash
make update-repos REPO_URL=https://github.com/YOUR-USERNAME/nlit2025.git
```

### 4. Deploy the Operator Stack

```bash
oc apply -f instructlab-gitops/argocd/app-of-apps.yaml -n openshift-gitops
```

Monitor the deployment:

```bash
oc get applications -n openshift-gitops
```

### 5. Deploy the InstructLab Pipeline

```bash
oc apply -f instructlab-gitops/argocd/instructlab-pipeline-app.yaml -n openshift-gitops
```

### 6. Verify the Installation

```bash
oc get pods -n data-science-project
```

## Next Steps

1. [Configure external model access](./custom-config.md#configuring-external-models)
2. [Run your first pipeline](../pipeline/running.md)
3. [Explore the UI](../operations/ui-access.md)

## Troubleshooting

If you encounter issues during installation, refer to:

1. [Common Installation Issues](../troubleshooting/installation-issues.md)
2. [Argo CD Troubleshooting](../troubleshooting/argocd-issues.md)