# lol-iot.iac

# Kubespray

[Kubespray](https://wiki.loliot.net/docs/mlops/mlops/kubernetes/tools/kubespray)

# Home lol-iot cluster

## Terragrunt

```shell
cd home/lol-iot/terragrunt \
&& terragrunt dag graph | dot -Tsvg -Nshape=rect -Gsplines=ortho > graph.svg
```

![Dependencies](assets/home/lol-iot/terragrunt/graph.svg)
