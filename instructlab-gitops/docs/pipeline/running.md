# Running the InstructLab Pipeline

This guide provides instructions for running the InstructLab pipeline.

## Prerequisites

Before running the pipeline, ensure:

1. The InstructLab pipeline is installed
2. External model access is configured
3. GPU resources are available
4. Storage is properly configured
5. OCI registry access is configured

## Running the Pipeline from CLI

### 1. Configure Pipeline Parameters

Create a parameter file or use the provided template:

```bash
# Copy the template
cp scripts/pipeline-parameters.env my-run-parameters.env

# Edit the parameters
nano my-run-parameters.env
```

Update the required parameters in the file:

```properties
# Required parameters
SDG_BASE_MODEL="s3://your-bucket/instructlab-base-model"
SDG_REPO_URL="https://github.com/your-organization/taxonomy.git"
OUTPUT_OCI_MODEL_URI="quay.io/your-org/instructlab-model:latest"

# Optional parameters
TRAIN_NUM_WORKERS="4"
TRAIN_MEMORY_PER_WORKER="120Gi"
SDG_BATCH_SIZE="16"
```

### 2. Run the Pipeline

Use the provided script to run the pipeline:

```bash
# Run with default parameters
make run-pipeline ENV=dev

# Run with custom parameters
make run-pipeline ENV=dev PARAMS_FILE=my-run-parameters.env
```

Alternatively, use the script directly:

```bash
./scripts/create-pipeline-run.sh dev my-run-parameters.env
```

### 3. Monitor the Pipeline Run

Monitor the pipeline run using the OpenShift CLI:

```bash
# Get the pipeline run status
oc get pipelineruns -n data-science-project

# Get the pipeline run details
oc describe pipelinerun instructlab-run-20230501-123456 -n data-science-project

# Get the logs for a specific task
oc logs -f $(oc get pods -n data-science-project -l tekton.dev/pipelineTask=training-phase-1 -o name) -n data-science-project
```

## Running from OpenShift AI Dashboard

### 1. Access the Dashboard

Navigate to the OpenShift AI dashboard:

```
https://console-openshift-console.apps.your-cluster.example.com/datasciencepipelines
```

### 2. Create Pipeline Run

1. Navigate to the Pipelines section
2. Select "InstructLab Pipeline"
3. Click "Create Run"
4. Fill in the parameters:
   - **SDG Base Model**: The base model URI
   - **SDG Repo URL**: The taxonomy repository URL
   - **Output OCI Model URI**: The output model URI
   - Additional parameters as needed
5. Click "Run" to start the pipeline

### 3. Monitor the Pipeline Run

1. Monitor the pipeline run in the dashboard
2. View logs for each task
3. Check the outputs and artifacts

## Pipeline Run Lifecycle

1. **Initialization** - Pipeline resources are created
2. **Execution** - Pipeline tasks are executed in sequence
3. **Completion** - Pipeline results are collected
4. **Cleanup** - Pipeline resources are cleaned up (if configured)

## Common Pipeline Run Scenarios

### 1. Basic Training Run

Configure minimal parameters for a basic training run:

```properties
SDG_BASE_MODEL="s3://your-bucket/instructlab-base-model"
SDG_REPO_URL="https://github.com/your-organization/taxonomy.git"
OUTPUT_OCI_MODEL_URI="quay.io/your-org/instructlab-model:latest"
```

### 2. High-Performance Training Run

Configure for higher performance:

```properties
SDG_BASE_MODEL="s3://your-bucket/instructlab-base-model"
SDG_REPO_URL="https://github.com/your-organization/taxonomy.git"
OUTPUT_OCI_MODEL_URI="quay.io/your-org/instructlab-model:latest"
TRAIN_NUM_WORKERS="8"
TRAIN_MEMORY_PER_WORKER="200Gi"
SDG_BATCH_SIZE="32"
SDG_NUM_WORKERS="8"
```

### 3. Experimental Run

Configure for experimentation:

```properties
SDG_BASE_MODEL="s3://your-bucket/instructlab-base-model"
SDG_REPO_URL="https://github.com/your-organization/taxonomy.git"
OUTPUT_OCI_MODEL_URI="quay.io/your-org/instructlab-model:experimental"
TRAIN_EPOCHS_PHASE_1="3"
TRAIN_EPOCHS_PHASE_2="5"
TRAIN_LEARNING_RATE="3e-5"
```

## Troubleshooting Pipeline Runs

### 1. Pipeline Run Fails to Start

If the pipeline run fails to start:

1. Check parameter values
2. Check resource availability
3. Check service account permissions

```bash
# Check for resource constraints
oc get quota -n data-science-project

# Check for service account permissions
oc get rolebindings -n data-science-project | grep pipeline
```

### 2. Task Failures

If a specific task fails:

1. Check the task logs
2. Check resource utilization
3. Check external dependencies

```bash
# Get the task pod name
TASK_POD=$(oc get pods -n data-science-project -l tekton.dev/pipelineTask=failed-task -o name)

# Get logs
oc logs -f $TASK_POD -n data-science-project
```

### 3. Performance Issues

If the pipeline runs slowly:

1. Check resource allocation
2. Check external service performance
3. Check data volumes

```bash
# Check pod resource usage
oc adm top pods -n data-science-project

# Check node resource usage
oc adm top nodes
```

## Pipeline Run Cleanup

To clean up completed pipeline runs:

```bash
# Delete old pipeline runs
oc delete pipelineruns --field-selector status.completionTime\<$(date -d "7 days ago" +%Y-%m-%dT%H:%M:%SZ) -n data-science-project