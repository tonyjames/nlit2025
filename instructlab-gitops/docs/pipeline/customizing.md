# Customizing the InstructLab Pipeline

This guide provides information on customizing the InstructLab pipeline for specific requirements.

## Customization Options

The InstructLab pipeline can be customized in several ways:

1. **Parameter Customization** - Modify pipeline parameters
2. **Task Customization** - Modify pipeline tasks
3. **Resource Customization** - Modify resource allocations
4. **Integration Customization** - Modify external integrations

## Parameter Customization

The simplest way to customize the pipeline is through parameters.

### 1. Environment-Specific Parameters

Customize parameters for different environments:

```yaml
# Create a custom environment overlay
mkdir -p overlays/custom
cat > overlays/custom/kustomization.yaml << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../../base

patches:
- path: pipeline-patch.yaml

configMapGenerator:
- name: instructlab-pipeline-params
  behavior: merge
  literals:
  - k8s_storage_class_name=my-storage-class
  - train_gpu_identifier=nvidia.com/gpu
  - sdg_batch_size=24
  - sdg_num_workers=6
  - train_num_workers=3
  - train_memory_per_worker=150Gi
EOF
```

### 2. Runtime Parameters

Customize parameters at runtime:

```bash
# Create a custom parameter file
cat > custom-parameters.env << EOF
SDG_BASE_MODEL="s3://your-bucket/instructlab-base-model"
SDG_REPO_URL="https://github.com/your-organization/taxonomy.git"
OUTPUT_OCI_MODEL_URI="quay.io/your-org/instructlab-model:custom"
TRAIN_NUM_WORKERS="3"
TRAIN_MEMORY_PER_WORKER="150Gi"
SDG_BATCH_SIZE="24"
EOF

# Run with custom parameters
make run-pipeline ENV=dev PARAMS_FILE=custom-parameters.env
```

## Task Customization

Customize pipeline tasks for specific requirements.

### 1. Modifying Task Resources

Customize task resource allocations:

```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: instructlab
spec:
  tasks:
  - name: training-phase-1
    resources:
      requests:
        cpu: 8
        memory: 32Gi
        nvidia.com/gpu: 2
      limits:
        cpu: 16
        memory: 64Gi
        nvidia.com/gpu: 2
```

### 2. Adding Custom Tasks

Add custom tasks to the pipeline:

```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: instructlab
spec:
  tasks:
  - name: custom-preprocessing
    taskRef:
      name: custom-preprocessing-task
    runAfter:
      - data-preparation
    params:
    - name: input-dir
      value: $(tasks.data-preparation.results.output-dir)
    - name: output-dir
      value: $(workspaces.shared-workspace.path)/preprocessed
```

Create the custom task:

```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: custom-preprocessing-task
spec:
  params:
  - name: input-dir
    type: string
  - name: output-dir
    type: string
  steps:
  - name: preprocess
    image: quay.io/your-org/custom-preprocessing:latest
    command:
    - /bin/bash
    - -c
    - |
      set -e
      echo "Preprocessing data..."
      python /app/preprocess.py --input-dir $(params.input-dir) --output-dir $(params.output-dir)
```

## Resource Customization

Customize resource allocations for improved performance.

### 1. Storage Customization

Customize storage resources:

```yaml
apiVersion: datasciencepipelinesapplications.opendatahub.io/v1alpha1
kind: DataSciencePipelinesApplication
metadata:
  name: dspa
spec:
  persistentStorage:
    storageClassName: high-performance-storage
    size: 500Gi
```

### 2. Compute Customization

Customize compute resources:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: instructlab-pipeline-params
data:
  train_num_workers: "8"
  train_memory_per_worker: "250Gi"
  train_cpu_limit: "16"
  train_gpu_count: "4"
```

## Integration Customization

Customize integrations with external systems.

### 1. External Model Customization

Customize external model access:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: teacher-secret
type: Opaque
stringData:
  api_token: "your-custom-token"
  model_name: "custom-model-name"
  endpoint: "https://custom-model-endpoint.example.com/v1"
```

### 2. Storage Integration Customization

Customize storage integration:

```yaml
apiVersion: datasciencepipelinesapplications.opendatahub.io/v1alpha1
kind: DataSciencePipelinesApplication
metadata:
  name: dspa
spec:
  objectStorage:
    externalStorage:
      bucket: custom-bucket
      host: custom-s3-endpoint.example.com
      region: us-west-2
      scheme: https
      s3CredentialsSecret:
        secretName: custom-s3-secret
```

## Advanced Customization

For more advanced customization needs:

### 1. Custom Container Images

Create custom container images for pipeline tasks:

```dockerfile
FROM quay.io/modh/odh-pipeline-rest-server:v2-latest

# Install custom dependencies
RUN pip install custom-package

# Add custom scripts
COPY custom-scripts /app/custom-scripts

# Set environment variables
ENV CUSTOM_CONFIG=/app/custom-config.json
```

### 2. Custom Metrics

Implement custom metrics collection:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: custom-metrics-monitor
  labels:
    app: instructlab-pipeline
spec:
  endpoints:
  - interval: 15s
    port: metrics
    path: /custom-metrics
  selector:
    matchLabels:
      app: instructlab-pipeline
```

### 3. Custom Notifications

Implement custom notifications:

```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: send-notification
spec:
  params:
  - name: status
    type: string
  - name: model-name
    type: string
  steps:
  - name: send
    image: curlimages/curl
    script: |
      curl -X POST \
        -H "Content-Type: application/json" \
        -d '{"status": "$(params.status)", "model": "$(params.model-name)"}' \
        https://your-notification-service.example.com/api/notify
```