# Development Environment Setup

This guide provides detailed instructions for setting up a development environment for InstructLab on OpenShift AI.

## Installation Steps

### 1. Fork and Clone the Repository

```bash
git clone https://github.com/YOUR-USERNAME/nlit2025.git
cd nlit2025
```

### 2. Update Repository URLs

Update the Argo CD application definitions to point to your fork:

```bash
make update-repos REPO_URL=https://github.com/YOUR-USERNAME/nlit2025.git
```

### 3. Install Required Tools

```bash
make install-tools
```

### 4. Deploy the Development Stack

Deploy operators with development configuration:

```bash
make apply-operators ENV=dev
```

Deploy the pipeline with development configuration:

```bash
make apply-pipeline ENV=dev
```

### 5. Configure Development Secrets

Update the external model secrets for development:

```bash
# Create a development version of the teacher secret
oc create secret generic teacher-secret \
  --from-literal=api_token=YOUR_DEV_TOKEN \
  --from-literal=model_name=mixtral \
  --from-literal=endpoint=https://dev-teacher-model.example.com/v1 \
  -n data-science-project

# Create a development version of the judge secret
oc create secret generic judge-secret \
  --from-literal=api_token=YOUR_DEV_TOKEN \
  --from-literal=model_name=prometheus \
  --from-literal=endpoint=https://dev-judge-model.example.com/v1 \
  -n data-science-project
```

### 6. Configure Development Parameters

Update the pipeline parameters for development:

```bash
# Create development-specific pipeline parameters
cp scripts/pipeline-parameters.env scripts/pipeline-parameters-dev.env
```

Edit `scripts/pipeline-parameters-dev.env` to set your development-specific values.

## Development Workflow

### Making Changes

1. Create a branch for your changes:

```bash
git checkout -b feature
```

2. Make your changes to the configuration
3. Validate the changes:

```bash
make validate-all ENV=dev
```

4. Apply the changes:

```bash
make apply-pipeline ENV=dev
```

5. Commit and push your changes:

```bash
git add file_changed_1 file_changed_2 ...
git commit -s -m "Add my new feature"
git push origin feature
```

### Testing the Pipeline

1. Run the pipeline with development parameters:

```bash
make run-pipeline ENV=dev PARAMS_FILE=scripts/pipeline-parameters-dev.env
```

2. Monitor the pipeline run:

```bash
oc get pipelineruns -n data-science-project
```

## Resource Optimization (UNDER TESTING)

The development environment uses reduced resource requests:

| Component | Development | Production |
|-----------|-------------|------------|
| Pipeline Replicas | 1 | 2+ |
| GPU Workers | 1-2 | 4+ |
| Storage | 20 GB | 100+ GB |

## Local Development Tips

1. View logs directly:

```bash
oc logs -f deployment/instructlab-pipeline -n data-science-project
```

2. Test changes before pushing:

```bash
kustomize build overlays/dev | oc apply --dry-run=client -f -
```