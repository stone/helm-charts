#!/usr/bin/env bats

load '_config_setup'

@test "Liveness probe is configured" {
    run bash -c "kubectl get deployment -n ${NAMESPACE} ${RELEASE_NAME}-meerkat-crm -o jsonpath='{.spec.template.spec.containers[0].livenessProbe.httpGet.path}'"
    [ "$status" -eq 0 ]
    [ "$output" = "/health" ]
}

@test "Readiness probe is configured" {
    run bash -c "kubectl get deployment -n ${NAMESPACE} ${RELEASE_NAME}-meerkat-crm -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}'"
    [ "$status" -eq 0 ]
    [ "$output" = "/health" ]
}
