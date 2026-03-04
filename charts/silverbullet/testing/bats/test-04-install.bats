#!/usr/bin/env bats

load '_config_setup'

@test "Helm chart installs successfully" {
    run helm install ${RELEASE_NAME} . --namespace ${NAMESPACE} --wait --timeout 5m
    [ "$status" -eq 0 ]
}

@test "Deployment is created" {
    run kubectl get deployment -n ${NAMESPACE} ${RELEASE_NAME}-silverbullet
    [ "$status" -eq 0 ]
}

@test "Service is created" {
    run kubectl get service -n ${NAMESPACE} ${RELEASE_NAME}-silverbullet
    [ "$status" -eq 0 ]
}

@test "PersistentVolumeClaim is created" {
    run kubectl get pvc -n ${NAMESPACE} ${RELEASE_NAME}-silverbullet-data
    [ "$status" -eq 0 ]
}

@test "PVC is bound" {
    run bash -c "kubectl get pvc -n ${NAMESPACE} ${RELEASE_NAME}-silverbullet-data -o jsonpath='{.status.phase}'"
    [ "$status" -eq 0 ]
    [ "$output" = "Bound" ]
}

@test "ServiceAccount is created" {
    run kubectl get serviceaccount -n ${NAMESPACE} ${RELEASE_NAME}-silverbullet
    [ "$status" -eq 0 ]
}
