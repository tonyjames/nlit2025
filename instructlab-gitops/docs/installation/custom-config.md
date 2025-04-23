# Custom Configuration Guide

This guide explains how to customize the InstructLab installation for your specific environment and requirements.

## Configuration Options

InstructLab provides several customization points:

1. **Environment Overlays** - Development and production configurations
2. **ConfigMaps** - Runtime parameters
3. **Secrets** - Sensitive connection information
4. **Storage Configuration** - Persistent storage settings
5. **GPU Configuration** - Accelerator settings

## Customizing Environment Overlays

The environment overlays in `overlays/dev` and `overlays/prod` provide environment-specific configurations.

To create a custom environment overlay:

```bash
# Create a new environment overlay
cp -r overlays/dev overlays/custom

# Edit the kustomization.yaml file
vim overlays/custom/kustomization.yaml
```

Update the appropriate configuration files in your custom overlay.

## Customizing ConfigMaps

The pipeline parameters are defined in ConfigMaps:

```bash
# View current configuration
oc get configmap instructlab-pipeline-params -n data-science-project -o yaml

# Create a custom configuration
cat > custom-params.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: instructlab-pipeline-params
data:
  k8s_storage_class_name: custom-storage-class
  train_gpu_identifier: nvidia.com/gpu
  sdg_batch_size: 24
  sdg_num_workers: 6
  train_num_workers: 3
  train_memory_per_worker: 150Gi
EOF

oc apply -f custom-params.yaml -n data-science-project
```

## Customizing External Model Access

Configure the external model secrets:

```bash
# Create a custom teacher model secret
oc create secret generic teacher-secret \
  --from-literal=api_token=YOUR_TOKEN \
  --from-literal=model_name=YOUR_MODEL_NAME \
  --from-literal=endpoint=https://your-model-endpoint.com/v1 \
  -n data-science-project

# Create a custom judge model secret
oc create secret generic judge-secret \
  --from-literal=api_token=YOUR_TOKEN \
  --from-literal=model_name=YOUR_MODEL_NAME \
  --from-literal=endpoint=https://your-model-endpoint.com/v1 \
  -n data-science-project
```

## Customizing GPU Configuration

Update the GPU configuration:

```bash
cat > gpu-patch.yaml << EOF
apiVersion: dashboard.opendatahub.io/v1
kind: AcceleratorProfile
metadata:
  name: migrated-gpu
  namespace: redhat-ods-applications
spec:
  displayName: Custom GPU Configuration
  enabled: true
  identifier: nvidia.com/gpu
  tolerations:
  - effect: NoSchedule
    key: nvidia.com/gpu
    operator: Exists
EOF

oc apply -f gpu-patch.yaml
```

## Applying Custom Configuration Through Kustomize

For more complex customizations, use Kustomize:

```bash
# Create a custom overlay
mkdir -p overlays/custom
cat > overlays/custom/kustomization.yaml << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../../base

patches:
- path: pipeline-patch.yaml
- path: secrets-patch.yaml

configMapGenerator:
- name: instructlab-pipeline-params
  behavior: merge
  literals:
  - k8s_storage_class_name=my-storage-class
  - train_gpu_identifier=nvidia.com/gpu
  - sdg_batch_size=24
  - sdg_num_workers=6
EOF

# Create custom patches
cat > overlays/custom/pipeline-patch.yaml << EOF
apiVersion: datasciencepipelinesapplications.opendatahub.io/v1alpha1
kind: DataSciencePipelinesApplication
metadata:
  name: dspa
spec:
  persistentStorage:
    storageClassName: my-storage-class
    size: 50Gi
EOF

# Apply the custom configuration
oc apply -k overlays/custom
```

## Configuration Parameter Reference

| Parameter | Description | Default (Dev) | Default (Prod) |
|-----------|-------------|--------------|----------------|
| `k8s_storage_class_name` | Storage class for persistence | `gp3-csi` | `gp3-csi` |
| `train_gpu_identifier` | GPU resource identifier | `nvidia.com/gpu` | `nvidia.com/gpu` |
| `sdg_batch_size` | Batch size for SDG | `16` | `32` |
| `sdg_num_workers` | Number of SDG workers | `4` | `8` |
| `train_num_workers` | Number of training workers | `2` | `4` |
| `train_memory_per_worker` | Memory per worker | `120Gi` | `200Gi` |