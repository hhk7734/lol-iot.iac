#!/bin/sh

set -e
set -x

sudo k0s kubeconfig create admin --groups system:masters >kubeconfig
