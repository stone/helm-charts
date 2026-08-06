#!/usr/bin/env bats

load '_config_setup'

@test "Pod is created" {
    run kubectl get pods -n ${NAMESPACE} -l app.kubernetes.io/name=meerkat-crm
    [ "$status" -eq 0 ]
}

@test "Pod becomes ready" {
    run bash -c "kubectl get pods -n ${NAMESPACE} -l app.kubernetes.io/name=meerkat-crm,app.kubernetes.io/instance=${RELEASE_NAME} --field-selector=status.phase=Running -o name | xargs -r kubectl wait -n ${NAMESPACE} --for=condition=Ready --timeout=5m"
    [ "$status" -eq 0 ]
}

@test "Pod is running" {
    run bash -c "kubectl get pods -n ${NAMESPACE} -l app.kubernetes.io/name=meerkat-crm -o jsonpath='{.items[0].status.phase}'"
    [ "$status" -eq 0 ]
    [ "$output" = "Running" ]
}

@test "Container is using correct image" {
    run bash -c "kubectl get deployment -n ${NAMESPACE} ${RELEASE_NAME}-meerkat-crm -o jsonpath='{.spec.template.spec.containers[0].image}'"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "ghcr.io/fbuchner/meerkat-crm" ]]
}

@test "Container port is 8080" {
    run bash -c "kubectl get deployment -n ${NAMESPACE} ${RELEASE_NAME}-meerkat-crm -o jsonpath='{.spec.template.spec.containers[0].ports[0].containerPort}'"
    [ "$status" -eq 0 ]
    [ "$output" = "8080" ]
}

@test "Volume is mounted at /app/data" {
    run bash -c "kubectl get deployment -n ${NAMESPACE} ${RELEASE_NAME}-meerkat-crm -o jsonpath='{.spec.template.spec.containers[0].volumeMounts[?(@.name==\"data\")].mountPath}'"
    [ "$status" -eq 0 ]
    [ "$output" = "/app/data" ]
}

@test "Application logs are available" {
    run kubectl logs -n ${NAMESPACE} -l app.kubernetes.io/name=meerkat-crm --tail=10
    [ "$status" -eq 0 ]
}

@test "Service is accessible" {
    run kubectl get service -n ${NAMESPACE} ${RELEASE_NAME}-meerkat-crm -o jsonpath='{.spec.ports[0].port}'
    [ "$status" -eq 0 ]
    [ "$output" = "8080" ]
}
