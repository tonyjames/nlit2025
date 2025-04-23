# Monitoring Pipeline Execution

This guide provides information on monitoring the execution of the InstructLab pipeline.

## Monitoring Options

The InstructLab pipeline can be monitored through several interfaces:

1. **OpenShift AI Dashboard** - Web-based dashboard
2. **OpenShift CLI** - Command-line monitoring
3. **Prometheus/Grafana** - Metrics monitoring
4. **Log Aggregation** - Log monitoring
5. **Custom Monitoring** - Custom monitoring solutions

## OpenShift AI Dashboard Monitoring

### 1. Accessing the Dashboard

Navigate to the OpenShift AI dashboard:

```
https://console-openshift-console.apps.your-cluster.example.com/datasciencepipelines
```

### 2. Pipeline Run View

1. Navigate to the Pipelines section
2. Select the pipeline run to monitor
3. View the pipeline graph
4. Click on individual tasks to view details
5. View logs for each task

### 3. Experiment Tracking

1. Navigate to the Experiments section
2. View experiment metrics
3. Compare experiment results

## OpenShift CLI Monitoring

### 1. Viewing Pipeline Runs

```bash
# List all pipeline runs
oc get pipelineruns -n data-science-project

# Get details for a specific pipeline run
oc describe pipelinerun instructlab-run-20230501-123456 -n data-science-project
```

### 2. Viewing Task Status

```bash
# Get task run status for a pipeline run
oc get taskruns -l tekton.dev/pipelineRun=instructlab-run-20230501-123456 -n data-science-project
```

### 3. Viewing Logs

```bash
# Get logs for a specific task
TASK_POD=$(oc get pods -n data-science-project -l tekton.dev/pipelineTask=training-phase-1,tekton.dev/pipelineRun=instructlab-run-20230501-123456 -o name)
oc logs -f $TASK_POD -n data-science-project
```

## Prometheus/Grafana Monitoring

### 1. Available Metrics

The pipeline exposes the following metrics:

- `pipeline_runs_total` - Total number of pipeline runs
- `pipeline_run_duration_seconds` - Duration of pipeline runs
- `task_runs_total` - Total number of task runs
- `task_run_duration_seconds` - Duration of task runs
- `pipeline_run_status` - Status of pipeline runs
- `gpu_utilization` - GPU utilization during training
- `memory_utilization` - Memory utilization during training

### 2. Accessing Metrics

Access metrics through Prometheus:

```
https://prometheus-k8s-openshift-monitoring.apps.your-cluster.example.com
```

### 3. Grafana Dashboards

Access Grafana dashboards:

```
https://grafana-openshift-monitoring.apps.your-cluster.example.com
```

Recommended dashboards:

- InstructLab Pipeline Overview
- InstructLab Training Performance
- InstructLab Resource Utilization

## Log Aggregation Monitoring

### 1. EFK Stack

If using the EFK (Elasticsearch, Fluentd, Kibana) stack:

1. Access Kibana:

```
https://kibana-openshift-logging.apps.your-cluster.example.com
```

2. Search for pipeline logs:

```
kubernetes.namespace_name:"data-science-project" AND kubernetes.labels.tekton.dev/pipeline:"instructlab"
```

### 2. Log Queries

Useful log queries:

- Training progress:

```
kubernetes.labels.tekton.dev/pipelineTask:"training-phase-1" AND "Epoch"
```

- Errors:

```
kubernetes.namespace_name:"data-science-project" AND level:"error"
```

## Custom Monitoring Tools

### 1. Webhook Notifications

Configure webhook notifications for pipeline events:

```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: send-notification
spec:
  params:
  - name: status
    type: string
  - name: pipeline-run
    type: string
  steps:
  - name: send
    image: curlimages/curl
    script: |
      curl -X POST \
        -H "Content-Type: application/json" \
        -d '{"status": "$(params.status)", "pipelineRun": "$(params.pipeline-run)"}' \
        https://your-notification-service.example.com/api/notify
```

### 2. Custom Dashboards

Create custom monitoring dashboards:

```yaml
apiVersion: integreatly.org/v1alpha1
kind: GrafanaDashboard
metadata:
  name: instructlab-custom-dashboard
  labels:
    app: grafana
spec:
  json: |
    {
      "annotations": { ... },
      "editable": true,
      "gnetId": null,
      "graphTooltip": 0,
      "id": null,
      "links": [],
      "panels": [ ... ],
      "refresh": "5s",
      "schemaVersion": 16,
      "style": "dark",
      "tags": ["instructlab", "pipeline"],
      "time": { ... },
      "timepicker": { ... },
      "timezone": "",
      "title": "InstructLab Custom Dashboard",
      "version": 0
    }
```