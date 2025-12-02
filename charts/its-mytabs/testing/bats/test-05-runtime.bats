#!/usr/bin/env bats

load '_config_setup'

@test "Pod is created" {
    run kubectl get pods -n ${NAMESPACE} -l app.kubernetes.io/name=its-mytabs
    [ "$status" -eq 0 ]
}

@test "Pod becomes ready" {
    run kubectl wait --for=condition=Ready pods -l app.kubernetes.io/name=its-mytabs -n ${NAMESPACE} --timeout=5m
    [ "$status" -eq 0 ]
}

@test "Pod is running" {
    run bash -c "kubectl get pods -n ${NAMESPACE} -l app.kubernetes.io/name=its-mytabs -o jsonpath='{.items[0].status.phase}'"
    [ "$status" -eq 0 ]
    [ "$output" = "Running" ]
}

@test "Container is using correct image" {
    run bash -c "kubectl get deployment -n ${NAMESPACE} ${RELEASE_NAME}-its-mytabs -o jsonpath='{.spec.template.spec.containers[0].image}'"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "louislam/its-mytabs" ]]
}

@test "Container port is 47777" {
    run bash -c "kubectl get deployment -n ${NAMESPACE} ${RELEASE_NAME}-its-mytabs -o jsonpath='{.spec.template.spec.containers[0].ports[0].containerPort}'"
    [ "$status" -eq 0 ]
    [ "$output" = "47777" ]
}

@test "Volume is mounted at /app/data" {
    run bash -c "kubectl get deployment -n ${NAMESPACE} ${RELEASE_NAME}-its-mytabs -o jsonpath='{.spec.template.spec.containers[0].volumeMounts[0].mountPath}'"
    [ "$status" -eq 0 ]
    [ "$output" = "/app/data" ]
}

@test "Application logs are available" {
    run kubectl logs -n ${NAMESPACE} -l app.kubernetes.io/name=its-mytabs --tail=10
    [ "$status" -eq 0 ]
}
