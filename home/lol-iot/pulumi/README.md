## Home lol-IoT k8s cluster

### Deployment DAG

```mermaid
flowchart TB
    subgraph Core
        Network
    end

    subgraph Monitoring
        metrics-server
    end

    Core --> Monitoring
```
