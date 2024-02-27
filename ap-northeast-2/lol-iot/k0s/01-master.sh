#!/bin/sh

set -e
set -x

sudo k0s install controller \
    --config k0s.yaml \
    --enable-worker \
    --kubelet-extra-args "--node-ip=10.255.240.2" \
    --enable-dynamic-config

sudo k0s start

sudo k0s status -o yaml
