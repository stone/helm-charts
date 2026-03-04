#!/usr/bin/env bash

# Shared variables
export CLUSTER_NAME="silverbullet-test"
export RELEASE_NAME="test-release"
export NAMESPACE="test-silverbullet"

setup_file() {

    if ! kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
        echo "# Creating KIND cluster..." >&3
        kind create cluster --config ../kind-config.yaml --name ${CLUSTER_NAME} --wait 60s
    fi
    # Wait for cluster to be ready
    kubectl wait --for=condition=Ready nodes --all --timeout=60s
    kind get clusters >&3
    # Create namespace
    kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
    kubectl get nodes >&3
}

setup() {
    cd "${BATS_TEST_DIRNAME}"/../..
}
