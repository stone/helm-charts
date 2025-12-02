#!/usr/bin/env bats

load '_config_setup'

@test "Helm chart lints successfully" {
    run helm lint .
    [ "$status" -eq 0 ]
    [[ "$output" =~ "1 chart(s) linted, 0 chart(s) failed" ]]
}

@test "Helm template renders without errors" {
    run helm template ${RELEASE_NAME} .
    [ "$status" -eq 0 ]
}

@test "Helm template generates Deployment" {
    run bash -c "helm template ${RELEASE_NAME} . | grep 'kind: Deployment'"
    [ "$status" -eq 0 ]
}

@test "Helm template generates Service" {
    run bash -c "helm template ${RELEASE_NAME} . | grep 'kind: Service'"
    [ "$status" -eq 0 ]
}

@test "Helm template generates PersistentVolumeClaim" {
    run bash -c "helm template ${RELEASE_NAME} . | grep 'kind: PersistentVolumeClaim'"
    [ "$status" -eq 0 ]
}

@test "Service uses correct port 47777" {
    port=$(helm template ${RELEASE_NAME} | yq 'select(.kind == "Service") | .spec.ports[0].port')
    if [ "$port" -ne 47777 ]; then
        echo "Expected port 47777, got $port" >&2
        return 1
    fi
}

@test "PVC mount path is /app/data" {
    helm template ${RELEASE_NAME} . | yq -e 'select(.kind == "Deployment") | .spec.template.spec.containers[].volumeMounts[] | select(.mountPath == "/app/data")' > /dev/null
}
