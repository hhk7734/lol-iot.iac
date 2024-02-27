#!/bin/sh

set -e
set -x

sudo k0s token create --role=worker --expiry=24h >token

cat token | base64 -d | gunzip -
