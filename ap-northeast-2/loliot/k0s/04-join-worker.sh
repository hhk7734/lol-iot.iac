#!/bin/sh

set -e
set -x

sudo k0s install worker \
    --token-file token \
    --kubelet-extra-args "--node-ip=10.255.240.4" \
    --labels node.kubernetes.io/role=worker \
    --taints node.cilium.io/agent-not-ready=true:NoExecute

sudo k0s start

sudo k0s status -o yaml
