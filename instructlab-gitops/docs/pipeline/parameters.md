# InstructLab Pipeline Parameters Reference

This document provides a detailed reference for the InstructLab pipeline parameters.

## Parameter Categories

The pipeline parameters are organized into the following categories:

1. **Model Parameters** - Control the models used in the pipeline
2. **Data Parameters** - Control data generation and processing
3. **Training Parameters** - Control the training process
4. **Infrastructure Parameters** - Control the underlying infrastructure
5. **Output Parameters** - Control the pipeline output

## Core Parameters

| Parameter | Description | Default | Valid Values | Required |
|-----------|-------------|---------|--------------|----------|
| `sdg_base_model` | Base model URI | - | S3 URI | Yes |
| `sdg_repo_url` | Taxonomy repository URL | - | Git URL | Yes |
| `output_oci_model_uri` | Output model URI | - | OCI URI | Yes |
| `output_oci_registry_secret` | OCI registry secret | `oci-registry-secret` | String | No |
| `output_model_name` | Output model name | `instructlab-model` | String | No |
| `output_model_version` | Output model version | `0.1.0` | Semantic version | No |
| `k8s_storage_class_name` | Storage class name | `gp3-csi` | String | No |
| `train_gpu_identifier` | GPU resource identifier | `nvidia.com/gpu` | String | No |
| `train_num_workers` | Number of training workers | `2` (dev), `4` (prod) | Integer | No |

## Synthetic Data Generation Parameters

| Parameter | Description | Default (Dev) | Default (Prod) | Valid Values |
|-----------|-------------|--------------|----------------|--------------|
| `sdg_scale_factor` | Number of instructions to generate | `30` | `30` | Integer > 0 |
| `sdg_batch_size` | Batch size for SDG | `16` | `32` | Integer > 0 |
| `sdg_num_workers` | Number of SDG workers | `4` | `8` | Integer > 0 |
| `sdg_random_seed` | Random seed for reproducibility | `42` | `42` | Integer |
| `sdg_quality_threshold` | Quality threshold for data | `0.7` | `0.7` | Float 0-1 |

## Training Parameters

| Parameter | Description | Default (Dev) | Default (Prod) | Valid Values |
|-----------|-------------|--------------|----------------|--------------|
| `train_epochs_phase_1` | Training epochs for phase 1 | `7` | `7` | Integer > 0 |
| `train_epochs_phase_2` | Training epochs for phase 2 | `10` | `10` | Integer > 0 |
| `train_learning_rate` | Learning rate | `2e-5` | `2e-5` | Float > 0 |
| `train_batch_size` | Training batch size | `8` | `16` | Integer > 0 |
| `train_sequence_length` | Maximum sequence length | `2048` | `2048` | Integer > 0 |
| `train_memory_per_worker` | Memory per worker | `120Gi` | `200Gi` | Memory string |
| `train_gradient_accumulation_steps` | Gradient accumulation steps | `4` | `4` | Integer > 0 |
| `train_cpu_limit` | CPU limit per worker | `4` | `8` | Integer > 0 |

## Evaluation Parameters

| Parameter | Description | Default | Valid Values |
|-----------|-------------|---------|--------------|
| `eval_num_samples` | Number of evaluation samples | `100` | Integer > 0 |
| `eval_batch_size` | Evaluation batch size | `16` | Integer > 0 |
| `eval_metrics` | Evaluation metrics | `accuracy,f1` | Comma-separated list |
| `eval_quality_threshold` | Quality threshold | `0.8` | Float 0-1 |

## Infrastructure Parameters

| Parameter | Description | Default (Dev) | Default (Prod) | Valid Values |
|-----------|-------------|--------------|----------------|--------------|
| `k8s_node_selector` | Node selector | `""` | `""` | JSON string |
| `k8s_tolerations` | Tolerations | `""` | `""` | JSON string |
| `k8s_storage_size` | Storage size | `20Gi` | `100Gi` | Storage string |
| `k8s_worker_resources` | Worker resources | `{"cpu":"4","memory":"120Gi"}` | `{"cpu":"8","memory":"200Gi"}` | JSON string |

## Output Parameters

| Parameter | Description | Default | Valid Values |
|-----------|-------------|---------|--------------|
| `output_save_checkpoints` | Save intermediate checkpoints | `false` | boolean |
| `output_checkpoint_frequency` | Checkpoint frequency | `1` | Integer > 0 |
| `output_save_metrics` | Save evaluation metrics | `true` | boolean |
| `output_metrics_format` | Metrics format | `json` | `json`, `csv` |

## Parameter Files

The pipeline parameters can be specified in a parameter file:

```bash
# Example parameter file: pipeline-parameters.env
SDG_BASE_MODEL="s3://your-bucket/instructlab-base-model"
SDG_REPO_URL="https://github.com/your-organization/taxonomy.git"
OUTPUT_OCI_MODEL_URI="quay.io/your-org/instructlab-model:latest"
TRAIN_NUM_WORKERS="4"
TRAIN_MEMORY_PER_WORKER="200Gi"
```

## Environment-Specific Parameters

Different environments (development, production) use different parameter defaults:

```yaml
# Development ConfigMap (excerpt)
configMapGenerator:
- name: instructlab-pipeline-params
  behavior: merge
  literals:
  - k8s_storage_class_name=gp3-csi
  - train_gpu_identifier=nvidia.com/gpu
  - sdg_batch_size=16
  - sdg_num_workers=4
  - train_num_workers=2
  - train_memory_per_worker=120Gi

# Production ConfigMap (excerpt)
configMapGenerator:
- name: instructlab-pipeline-params
  behavior: merge
  literals:
  - k8s_storage_class_name=gp3-csi
  - train_gpu_identifier=nvidia.com/gpu
  - sdg_batch_size=32
  - sdg_num_workers=8
  - train_num_workers=4
  - train_memory_per_worker=200Gi
```

## Parameter Update Procedure

To update parameters:

```bash
# Update a parameter in the ConfigMap
oc patch configmap instructlab-pipeline-params -n data-science-project --type merge -p '{"data":{"train_num_workers":"6"}}'
```