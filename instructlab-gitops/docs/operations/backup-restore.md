# Backup and Restore Procedures

This guide outlines procedures for backing up and restoring InstructLab components on OpenShift.

## Backup Strategy

A comprehensive backup strategy for InstructLab should include:

1. **GitOps Repository** - The source of truth for all configurations
2. **Persistent Volumes** - Storage used by the pipeline
3. **Secrets** - Sensitive configuration data

## Backup Procedures

### 1. GitOps Repository Backup

The Git repository could be backed up:

```bash
# Clone the repository
git clone https://github.com/your-org/nlit2025.git backup-repo

# Create a backup archive
tar -czf backup-$(date +%Y%m%d).tar.gz backup-repo
```

### 2. Persistent Volume Backup

Use OpenShift's snapshot capability:

```bash
# Create a volume snapshot
cat > volume-snapshot.yaml << EOF
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: dspa-pvc-snapshot-$(date +%Y%m%d)
  namespace: data-science-project
spec:
  volumeSnapshotClassName: csi-snapshot-class
  source:
    persistentVolumeClaimName: dspa-database
EOF

oc apply -f volume-snapshot.yaml
```

### 3. Secret Backup

Backup all secrets:

```bash
# Export secrets
mkdir -p backups/secrets/$(date +%Y%m%d)
oc get secret teacher-secret -n data-science-project -o yaml > backups/secrets/$(date +%Y%m%d)/teacher-secret.yaml
oc get secret judge-secret -n data-science-project -o yaml > backups/secrets/$(date +%Y%m%d)/judge-secret.yaml
oc get secret oci-registry-secret -n data-science-project -o yaml > backups/secrets/$(date +%Y%m%d)/oci-registry-secret.yaml
```

## Restore Procedures

### 1. GitOps Repository Restore

Restore from the Git repository:

```bash
# Push the repository to a new location if needed
cd backup-repo
git remote add new-origin https://github.com/your-org/new-repo.git
git push -u new-origin main
```

### 2. Persistent Volume Restore

Restore from a volume snapshot:

```bash
# Create a PVC from the snapshot
cat > pvc-from-snapshot.yaml << EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dspa-database-restored
  namespace: data-science-project
spec:
  dataSource:
    name: dspa-pvc-snapshot-20230501
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
EOF

oc apply -f pvc-from-snapshot.yaml
```

### 3. Secret Restore

Restore secrets:

```bash
# Apply the backed-up secrets
oc apply -f backups/secrets/20230501/teacher-secret.yaml
oc apply -f backups/secrets/20230501/judge-secret.yaml
oc apply -f backups/secrets/20230501/oci-registry-secret.yaml
```

## Disaster Recovery

For complete disaster recovery:

1. Deploy a new OpenShift cluster
2. Install the required operators
3. Restore the GitOps repository
4. Apply the configuration from the repository
5. Restore data from backups

## Backup Schedule

A potential backup schedule:

| Component | Frequency | Retention |
|-----------|-----------|-----------|
| GitOps Repository | Daily | 30 days |
| Persistent Volumes | Daily | 30 days |
| Secrets | Weekly | 30 days |
| Models | After each successful training | Indefinite |