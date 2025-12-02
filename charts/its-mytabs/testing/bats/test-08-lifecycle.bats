#!/usr/bin/env bats

load '_config_setup'

@test "Helm chart can be upgraded" {
    run helm upgrade ${RELEASE_NAME} . --namespace ${NAMESPACE} --wait --timeout 5m
    [ "$status" -eq 0 ]
}

@test "Helm chart uninstalls cleanly" {
    run helm uninstall ${RELEASE_NAME} --namespace ${NAMESPACE}
    [ "$status" -eq 0 ]
}

@test "Resources are cleaned up after uninstall" {
    sleep 5
    run kubectl get pods -n ${NAMESPACE} -l app.kubernetes.io/name=its-mytabs
    debug "The output: $output"
    [ "$status" -ne 0 ] || [ -z "$(echo $output | grep -v 'No resources found' | grep -v 'NAME')" ]
}
