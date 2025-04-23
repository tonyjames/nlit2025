# Production Environment Deployment

This guide provides detailed instructions for deploying InstructLab on OpenShift in a production environment

(DONT DO THAT BY USING THIS DIRECTLY, FOLLOW OFFICIAL DOCUMENTATION!!!!)

## Production Deployment Considerations

Production deployments of InstructLab require careful planning for:

1. **Scale** - Sufficient resources for production workloads
2. **Reliability** - High availability configuration
3. **Security** - Proper secret management and security controls
4. **Performance** - Optimized configuration for maximum performance
5. **Monitoring** - Comprehensive monitoring and alerting

## Pre-Deployment Checklist

Before deploying to production, ensure:

- [x] All prerequisites are met with production-grade resources
- [x] Production endpoints for external models are configured
- [x] Production secrets are properly encrypted
- [x] Storage is properly configured for production scale
- [x] Backup and restore procedures are in place
- [x] Monitoring and alerting is configured

## Deployment Steps

### 1. Prepare Production Configuration

```bash
# Ensure you're using a tagged, stable version
git checkout v1.0.0
```

### 2. Deploy Using Production Configuration

```bash
# Deploy operators with production configuration
make apply-operators ENV=prod

# Deploy pipeline with production configuration
make apply-pipeline ENV=prod
```

### 3. Configure Production Secrets

Production secrets should be encrypted using SealedSecrets or SOPS:

```bash
# Example using SealedSecrets
kubeseal -o yaml < teacher-secret.yaml > sealed-teacher-secret.yaml
oc apply -f sealed-teacher-secret.yaml -n data-science-project

kubeseal -o yaml < judge-secret.yaml > sealed-judge-secret.yaml
oc apply -f sealed-judge-secret.yaml -n data-science-project
```

### 4. Configure Production Parameters

Update the pipeline parameters for production:

```bash
# Create production-specific pipeline parameters
cp scripts/pipeline-parameters.env scripts/pipeline-parameters-prod.env
```

Edit `scripts/pipeline-parameters-prod.env` to set production-specific values.

### 5. Verify Production Deployment

```bash
# Verify all applications are synced and healthy
argocd app list -n openshift-gitops

# Verify all pods are running
oc get pods -n data-science-project
```

## Production Resource Requirements (STILL UNDER ACTUAL TESTING)

| Component | Minimum Resources | Recommended Resources |
|-----------|-------------------|----------------------|
| Pipeline Pods | 2 CPU, 4 GB RAM | 4 CPU, 8 GB RAM |
| Training Pods | 4 CPU, 16 GB RAM, 1 GPU | 8 CPU, 32 GB RAM, 2+ GPUs |
| Storage | 100 GB | 1+ TB |

## High Availability Configuration

For high availability, configure:

1. **Multiple Replicas** - Set replicas to 2+ for key components
2. **Pod Disruption Budgets** - Ensure availability during maintenance:

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: instructlab-pipeline-pdb
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: instructlab-pipeline
```

3. **Anti-Affinity Rules** - Ensure pods are distributed across nodes:

```yaml
spec:
  affinity:
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: app
              operator: In
              values:
              - instructlab-pipeline
          topologyKey: kubernetes.io/hostname
```

## Production Security Hardening

1. **Network Policies** - Restrict pod communication
2. **Security Context Constraints** - Limit pod privileges
3. **Resource Quotas** - Prevent resource exhaustion
4. **Regular Secret Rotation** - Implement automated secret rotation