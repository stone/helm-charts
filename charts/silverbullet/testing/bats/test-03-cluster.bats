#!/usr/bin/env bats

load '_config_setup'

@test "KIND cluster exists and is accessible" {
    run kind get clusters
    [ "$status" -eq 0 ]
    [[ "$output" =~ "${CLUSTER_NAME}" ]]
}

@test "Namespace exists" {
    run kubectl get namespace ${NAMESPACE}
    [ "$status" -eq 0 ]
}
