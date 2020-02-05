#!/bin/bash

set -e

THIS_FILE=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_FILE}")

docker build --force-rm -f Dockerfile.v1 -t localhost:32000/samples/kubernetes-bootcamp:v1 "${THIS_DIR}"
docker build --force-rm -f Dockerfile.v2 -t localhost:32000/samples/kubernetes-bootcamp:v2 "${THIS_DIR}"
