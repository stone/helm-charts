#!/usr/bin/env bash

# Shared variables
export CLUSTER_NAME="its-mytabs-test"
export RELEASE_NAME="test-release"
export NAMESPACE="test-mytabs"

# Debug helper function
debug() { [[ -n "${DEBUG:-}" ]] && echo "DEBUG: $*" >&2; }

# Suite-level setup (runs once before all tests)
setup_file() {
    echo "# Setting up test environment..." >&3

    command -v kind >/dev/null 2>&1 || {
        echo "ERROR: kind is not installed" >&3
        return 1
    }
    command -v helm >/dev/null 2>&1 || {
        echo "ERROR: helm is not installed" >&3
        return 1
    }
    command -v kubectl >/dev/null 2>&1 || {
        echo "ERROR: kubectl is not installed" >&3
        return 1
    }

    if ! kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
        echo "# Creating KIND cluster..." >&3
        kind create cluster --config ../kind-config.yaml --name ${CLUSTER_NAME} --wait 60s
    fi

    # Wait for cluster to be ready
    kubectl wait --for=condition=Ready nodes --all --timeout=60s
    # Create namespace
    kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
}

# Suite-level teardown (runs once after all tests)
teardown_file() {
    echo "# Test suite completed" >&3
    kind delete cluster --name ${CLUSTER_NAME}
}

# Test-level setup (runs before each test)
setup() {
    cd "${BATS_TEST_DIRNAME}"/../..
}
