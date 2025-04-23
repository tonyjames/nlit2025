# Scaling InstructLab

This guide provides information on scaling InstructLab components on OpenShift to handle different workloads.

## Scaling Dimensions

InstructLab can be scaled along several dimensions:

1. **Horizontal Scaling** - Adding more replicas of components
2. **Vertical Scaling** - Increasing resources for existing components
3. **Storage Scaling** - Expanding storage capacity
4. **GPU Scaling** - Adding or upgrading GPU resources

## Horizontal Scaling

### Pipeline Components

Increase replicas for pipeline components:

```yaml
apiVersion: datasciencepipelinesapplications.opendatahub.io/v1alpha1
kind: DataSciencePipelinesApplication
metadata:
  name: dspa
spec:
  apiServer:
    replicas: 2
  persistenceAgent:
    replicas: 2
    numWorkers: 4
  scheduledWorkflow:
    replicas: 2
```

### Training Workers

Increase the number of training workers:

```bash
# Update the ConfigMap
oc patch configmap instructlab-pipeline-params -n data-science-project --type merge -p '{"data":{"train_num_workers":"4"}}'
```

## Vertical Scaling

### Resource Requests

Update resource requests and limits:

```yaml
apiVersion: datasciencepipelinesapplications.opendatahub.io/v1alpha1
kind: DataSciencePipelinesApplication
metadata:
  name: dspa
spec:
  apiServer:
    resources:
      requests:
        cpu: 2
        memory: 4Gi
      limits:
        cpu: 4
        memory: 8Gi
```

### Worker Resources

Update worker resources:

```bash
# Update the ConfigMap
oc patch configmap instructlab-pipeline-params -n data-science-project --type merge -p '{"data":{"train_memory_per_worker":"200Gi"}}'
```

## Storage Scaling

### Persistent Volume Expansion

Expand existing persistent volumes:

```bash
# Update the PVC size
oc patch pvc dspa-database -n data-science-project --type merge -p '{"spec":{"resources":{"requests":{"storage":"20Gi"}}}}'
```

### Object Storage Configuration

Update object storage configuration:

```yaml
apiVersion: datasciencepipelinesapplications.opendatahub.io/v1alpha1
kind: DataSciencePipelinesApplication
metadata:
  name: dspa
spec:
  objectStorage:
    externalStorage:
      bucket: larger-bucket
```

## GPU Scaling

### GPU Workers

Increase the number of GPU workers:

```bash
# Update the ConfigMap
oc patch configmap instructlab-pipeline-params -n data-science-project --type merge -p '{"data":{"train_gpu_count":"2"}}'
```

### GPU Types

Configure different GPU types:

```yaml
apiVersion: dashboard.opendatahub.io/v1
kind: AcceleratorProfile
metadata:
  name: high-end-gpu
  namespace: redhat-ods-applications
spec:
  displayName: A100 GPU
  enabled: true
  identifier: nvidia.com/a100
  tolerations:
  - effect: NoSchedule
    key: nvidia.com/gpu
    operator: Exists
```

## Scaling Blocks

### Small Deployment (Development)

| Component | Replicas | Resources |
|-----------|----------|-----------|
| API Server | 1 | 1 CPU, 2Gi Memory |
| Persistence Agent | 1 | 0.5 CPU, 1Gi Memory |
| Scheduled Workflow | 1 | 0.5 CPU, 1Gi Memory |
| Database | 1 | 0.5 CPU, 1Gi Memory |
| Storage | 20Gi | gp3-csi |
| Training Workers | 2 | 120Gi Memory |
| GPUs | 1-2 | nvidia.com/gpu |

### Medium Deployment (Small Production)

| Component | Replicas | Resources |
|-----------|----------|-----------|
| API Server | 2 | 2 CPU, 4Gi Memory |
| Persistence Agent | 2 | 1 CPU, 2Gi Memory |
| Scheduled Workflow | 2 | 1 CPU, 2Gi Memory |
| Database | 1 | 2 CPU, 4Gi Memory |
| Storage | 100Gi | gp3-csi |
| Training Workers | 4 | 200Gi Memory |
| GPUs | 4 | nvidia.com/gpu |

### Large Deployment (Large Production)

| Component | Replicas | Resources |
|-----------|----------|-----------|
| API Server | 4 | 4 CPU, 8Gi Memory |
| Persistence Agent | 4 | 2 CPU, 4Gi Memory |
| Scheduled Workflow | 4 | 2 CPU, 4Gi Memory |
| Database | 2 | 4 CPU, 8Gi Memory |
| Storage | 1000Gi | gp3-csi |
| Training Workers | 8+ | 256Gi Memory |
| GPUs | 8+ | nvidia.com/gpu |