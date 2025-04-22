#!/bin/bash
set -e

# Script to create an InstructLab pipeline run from the template
# Usage: ./create-pipeline-run.sh [environment] [parameters_file]
# Example: ./create-pipeline-run.sh dev custom-params.env

# Default values
ENVIRONMENT=${1:-dev}
PARAMS_FILE=${2:-$(dirname "$0")/pipeline-parameters.env}
NAMESPACE=${NAMESPACE:-data-science-project}
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Load environment variables
if [ -f "$PARAMS_FILE" ]; then
  echo "Loading parameters from $PARAMS_FILE"
  source "$PARAMS_FILE"
else
  echo "Parameters file $PARAMS_FILE not found. Using default values."
fi

# Validate required parameters
if [ -z "$SDG_BASE_MODEL" ]; then
  echo "ERROR: SDG_BASE_MODEL must be set. Specify it in $PARAMS_FILE or as an environment variable."
  exit 1
fi

if [ -z "$SDG_REPO_URL" ]; then
  echo "ERROR: SDG_REPO_URL must be set. Specify it in $PARAMS_FILE or as an environment variable."
  exit 1
fi

if [ -z "$OUTPUT_OCI_MODEL_URI" ]; then
  echo "ERROR: OUTPUT_OCI_MODEL_URI must be set. Specify it in $PARAMS_FILE or as an environment variable."
  exit 1
fi

# Load StorageClass from ConfigMap (fallback to env var if not found)
if [ -z "$STORAGE_CLASS_NAME" ]; then
  STORAGE_CLASS_NAME=$(oc get configmap -n $NAMESPACE instructlab-pipeline-params-${ENVIRONMENT} -o jsonpath='{.data.k8s_storage_class_name}' 2>/dev/null || echo "nfs-csi")
fi

# Create a temporary file for the pipeline run
TMPFILE=$(mktemp)
cat "$(dirname "$0")/../base/pipeline/pipelinerun-template.yaml" > "$TMPFILE"

# Check if we're on macOS or Linux for sed compatibility
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS version
  sed -i '' "s|\${SDG_BASE_MODEL}|$SDG_BASE_MODEL|g" "$TMPFILE"
  sed -i '' "s|\${SDG_REPO_URL}|$SDG_REPO_URL|g" "$TMPFILE"
  sed -i '' "s|\${OUTPUT_OCI_MODEL_URI}|$OUTPUT_OCI_MODEL_URI|g" "$TMPFILE"
  sed -i '' "s|\${OCI_REGISTRY_SECRET}|${OCI_REGISTRY_SECRET:-oci-registry-secret}|g" "$TMPFILE"
  sed -i '' "s|\${OUTPUT_MODEL_NAME}|${OUTPUT_MODEL_NAME:-instructlab-model}|g" "$TMPFILE"
  sed -i '' "s|\${OUTPUT_MODEL_VERSION}|${OUTPUT_MODEL_VERSION:-0.1.0}|g" "$TMPFILE"
  sed -i '' "s|\${STORAGE_CLASS_NAME}|$STORAGE_CLASS_NAME|g" "$TMPFILE"
  sed -i '' "s|\${TRAIN_GPU_IDENTIFIER}|${TRAIN_GPU_IDENTIFIER:-nvidia.com/gpu}|g" "$TMPFILE"
  sed -i '' "s|\${TRAIN_NUM_WORKERS}|${TRAIN_NUM_WORKERS:-2}|g" "$TMPFILE"
  sed -i '' "s|generateName: instructlab-run-|generateName: instructlab-run-$TIMESTAMP-|g" "$TMPFILE"
  
  # Add additional parameters if provided
  if [ ! -z "$SDG_SCALE_FACTOR" ]; then
    sed -i '' "/^spec:/a\\
  - name: sdg_scale_factor\\
    value: \"$SDG_SCALE_FACTOR\"
" "$TMPFILE"
  fi

  if [ ! -z "$SDG_BATCH_SIZE" ]; then
    sed -i '' "/^spec:/a\\
  - name: sdg_batch_size\\
    value: \"$SDG_BATCH_SIZE\"
" "$TMPFILE"
  fi
else
  # Linux version
  sed -i "s|\${SDG_BASE_MODEL}|$SDG_BASE_MODEL|g" "$TMPFILE"
  sed -i "s|\${SDG_REPO_URL}|$SDG_REPO_URL|g" "$TMPFILE"
  sed -i "s|\${OUTPUT_OCI_MODEL_URI}|$OUTPUT_OCI_MODEL_URI|g" "$TMPFILE"
  sed -i "s|\${OCI_REGISTRY_SECRET}|${OCI_REGISTRY_SECRET:-oci-registry-secret}|g" "$TMPFILE"
  sed -i "s|\${OUTPUT_MODEL_NAME}|${OUTPUT_MODEL_NAME:-instructlab-model}|g" "$TMPFILE"
  sed -i "s|\${OUTPUT_MODEL_VERSION}|${OUTPUT_MODEL_VERSION:-0.1.0}|g" "$TMPFILE"
  sed -i "s|\${STORAGE_CLASS_NAME}|$STORAGE_CLASS_NAME|g" "$TMPFILE"
  sed -i "s|\${TRAIN_GPU_IDENTIFIER}|${TRAIN_GPU_IDENTIFIER:-nvidia.com/gpu}|g" "$TMPFILE"
  sed -i "s|\${TRAIN_NUM_WORKERS}|${TRAIN_NUM_WORKERS:-2}|g" "$TMPFILE"
  sed -i "s|generateName: instructlab-run-|generateName: instructlab-run-$TIMESTAMP-|g" "$TMPFILE"
  
  # Add additional parameters if provided
  if [ ! -z "$SDG_SCALE_FACTOR" ]; then
    sed -i '/^spec:/a\  - name: sdg_scale_factor\n    value: "'$SDG_SCALE_FACTOR'"' "$TMPFILE"
  fi

  if [ ! -z "$SDG_BATCH_SIZE" ]; then
    sed -i '/^spec:/a\  - name: sdg_batch_size\n    value: "'$SDG_BATCH_SIZE'"' "$TMPFILE"
  fi
fi

# Apply the pipeline run
echo "Creating InstructLab pipeline run in namespace $NAMESPACE..."
oc apply -f "$TMPFILE" -n "$NAMESPACE"
rm "$TMPFILE"

echo "Pipeline run created successfully."
