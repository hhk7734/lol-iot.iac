# lol-iot.iac

# Kubespray

```shell
docker run --rm -it \
  -v $(pwd)/inventory:/inventory \
  quay.io/kubespray/kubespray:v2.26.0 bash
```

# Home lol-iot cluster

## Terragrunt

![Dependencies](assets/home/lol-iot/terragrunt/graph.svg)
