#!/usr/bin/env bats

load '_config_setup'

@test "Liveness probe is configured" {
    run bash -c "kubectl get deployment -n ${NAMESPACE} ${RELEASE_NAME}-its-mytabs -o jsonpath='{.spec.template.spec.containers[0].livenessProbe.httpGet.path}'"
    [ "$status" -eq 0 ]
    [ "$output" = "/" ]
}

@test "Readiness probe is configured" {
    run bash -c "kubectl get deployment -n ${NAMESPACE} ${RELEASE_NAME}-its-mytabs -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}'"
    [ "$status" -eq 0 ]
    [ "$output" = "/" ]
}
