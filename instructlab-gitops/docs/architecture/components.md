# InstructLab Component Details

This document provides detailed information about each component in this architecture.

## GitOps Components

### OpenShift GitOps (Argo CD)

OpenShift GitOps is the foundation of the deployment strategy, ensuring that the desired state in Git is reflected in the cluster.

**Purpose:**
- Automated deployment of all components
- Configuration drift detection and reconciliation
- Deployment history and rollback capabilities

**Key Resources:**
- `app-of-apps.yaml` - Root application that deploys all operators
- `instructlab-pipeline-app.yaml` - Application that deploys the InstructLab pipeline

## Operator Stack

The following operators provide the core capabilities required by InstructLab:

### GPU Operator

**Purpose:** Provides GPU support for accelerated computing

**Key Resources:**
- `ClusterPolicy` - Configures GPU resources
- Requires NVIDIA GPUs in the cluster

### OpenShift AI Operator

**Purpose:** Deploys and configures the data science platform

**Key Resources:**
- `DataScienceCluster` - Core configuration for OpenShift AI
- `AcceleratorProfile` - GPU configuration for data science workloads

### Service Mesh Operator

**Purpose:** Provides service-to-service communication capabilities

**Key Resources:**
- Used by KServe for model serving

### Serverless Operator

**Purpose:** Enables scale-to-zero capabilities for serving components

**Key Resources:**
- Used by KServe for model serving

### Authorino Operator

**Purpose:** Provides authentication and authorization capabilities

**Key Resources:**
- Secures API endpoints

## Pipeline Components

### Data Science Pipeline Application

**Purpose:** Orchestrates the machine learning workflows

**Key Resources:**
- `DataSciencePipelinesApplication` - Pipeline configuration

### External Model Integration

**Purpose:** Connects to external Teacher and Judge models

**Key Resources:**
- `teacher-secret.yaml` - Connection details for Teacher model
- `judge-secret.yaml` - Connection details for Judge model

## Service Components

### UI Component

**Purpose:** Provides user interface for InstructLab

**Key Resources:**
- `Deployment` - UI application deployment
- `Service` - Kubernetes service for the UI
- `Route` - OpenShift route for external access