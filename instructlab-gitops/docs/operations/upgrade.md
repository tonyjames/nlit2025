# InstructLab Upgrade Guide

This guide provides procedures for upgrading InstructLab components on OpenShift.

## Upgrade Planning

Before upgrading, consider:

1. **Impact** - Potential downtime or performance impact
2. **Dependencies** - Required updates to prerequisites
3. **Testing** - Validation in a non-production environment
4. **Rollback** - Procedure if issues are encountered

## Standard Upgrade Procedure

### 1. Backup Current State

```bash
# Backup current configuration
mkdir -p backups/$(date +%Y%m%d)
oc get applications -n openshift-gitops -o yaml > backups/$(date +%Y%m%d)/applications.yaml
oc get datasciencepipelinesapplications -n data-science-project -o yaml > backups/$(date +%Y%m%d)/dspa.yaml
```

### 2. Update Repository

```bash
# Fetch the latest changes
git fetch origin

# Check out the desired version tag
git checkout v1.1.0
```

### 3. Validate the Upgrade

```bash
# Validate the configuration
make validate-all ENV=prod
```

### 4. Apply the Upgrade

```bash
# Update operators if needed
make apply-operators ENV=prod

# Update the pipeline
make apply-pipeline ENV=prod
```

### 5. Verify the Upgrade

```bash
# Verify applications are synced
argocd app list -n openshift-gitops

# Verify pods are running
oc get pods -n data-science-project
```

## Operator Upgrades

When upgrading operators, you can follow the default order of installation:

1. GPU Operator
2. Service Mesh Operator
3. Serverless Operator
4. Authorino Operator
5. OpenShift AI Operator

Example operator upgrade:

```bash
# Update the operator subscription
cat > operator-upgrade.yaml << EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: gpu-operator-certified
  namespace: openshift-operators
spec:
  channel: v24.6
  installPlanApproval: Automatic
  name: gpu-operator-certified
  source: certified-operators
  sourceNamespace: openshift-marketplace
  startingCSV: gpu-operator-certified.v24.6.1
EOF

oc apply -f operator-upgrade.yaml
```

## Pipeline Upgrades

To upgrade the pipeline:

```bash
# Update the pipeline image reference
cat > pipeline-upgrade.yaml << EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: instructlab-pipeline
  namespace: openshift-gitops
spec:
  source:
    kustomize:
      images:
      - quay.io/modh/odh-pipeline-rest-server:v2.1.0-latest
EOF

oc apply -f pipeline-upgrade.yaml
```

## Rolling Back an Upgrade

If issues are encountered, roll back to the previous version:

```bash
# Check out the previous version tag
git checkout v1.0.0

# Apply the previous version
make apply-operators ENV=prod
make apply-pipeline ENV=prod
```