#!/usr/bin/env bats

load '_config_setup'

@test "Helm template passes" {
    run helm template ${RELEASE_NAME} .
    [ "$status" -eq 0 ]
}

@test "Helm lint passes" {
    run helm lint .
    [ "$status" -eq 0 ]
}

# Deployment tests
@test "Helm template generates Deployment" {
    run bash -c "helm template ${RELEASE_NAME} . | grep 'kind: Deployment'"
    [ "$status" -eq 0 ]
}

@test "Deployment uses correct image" {
    local appVersion
    appVersion=$(yq '.appVersion' Chart.yaml | tr -d '"')
    image=$(helm template ${RELEASE_NAME} . | yq 'select(.kind == "Deployment") | .spec.template.spec.containers[0].image' | tr -d '"')
    [ "$image" = "ghcr.io/fbuchner/meerkat-crm:${appVersion}" ]
}

@test "Deployment sets custom image tag" {
    image=$(helm template ${RELEASE_NAME} . --set image.tag=1.0.0 | yq 'select(.kind == "Deployment") | .spec.template.spec.containers[0].image' | tr -d '"')
    [ "$image" = "ghcr.io/fbuchner/meerkat-crm:1.0.0" ]
}

@test "Deployment has default replica count of 1" {
    replicas=$(helm template ${RELEASE_NAME} . | yq 'select(.kind == "Deployment") | .spec.replicas')
    [ "$replicas" -eq 1 ]
}

@test "Deployment mounts data volume at /app/data" {
    helm template ${RELEASE_NAME} . | yq -e 'select(.kind == "Deployment") | .spec.template.spec.containers[0].volumeMounts[] | select(.name == "data" and .mountPath == "/app/data")' > /dev/null
}

@test "Deployment sets env environment when credentials provided" {
    helm template ${RELEASE_NAME} . --set env[0].name=JWT_SECRET_KEY --set env[0].value=test_key | \
        yq -e 'select(.kind == "Deployment") | .spec.template.spec.containers[0].env[] | select(.name == "JWT_SECRET_KEY" and .value == "test_key")' > /dev/null
}

@test "Deployment sets security context for pod" {
    fsGroup=$(helm template ${RELEASE_NAME} . | yq 'select(.kind == "Deployment") | .spec.template.spec.securityContext.fsGroup')
    [ "$fsGroup" -eq 1001 ]
}

@test "Deployment sets security context for container" {
    allowEscalation=$(helm template ${RELEASE_NAME} . | yq 'select(.kind == "Deployment") | .spec.template.spec.containers[0].securityContext.allowPrivilegeEscalation' | tr -d '"')
    [ "$allowEscalation" = "false" ]
}

# Service tests
@test "Helm template generates Service" {
    run bash -c "helm template ${RELEASE_NAME} . | grep 'kind: Service'"
    [ "$status" -eq 0 ]
}

@test "Service has correct type ClusterIP by default" {
    serviceType=$(helm template ${RELEASE_NAME} . | yq 'select(.kind == "Service") | .spec.type' | tr -d '"')
    [ "$serviceType" = "ClusterIP" ]
}

@test "Service exposes port 8080" {
    port=$(helm template ${RELEASE_NAME} . | yq 'select(.kind == "Service") | .spec.ports[] | select(.name == "http") | .port')
    [ "$port" -eq 8080 ]
}

@test "Service sets NodePort type when configured" {
    serviceType=$(helm template ${RELEASE_NAME} . --set service.type=NodePort | yq 'select(.kind == "Service") | .spec.type' | tr -d '"')
    [ "$serviceType" = "NodePort" ]
}

@test "Service sets LoadBalancer type when configured" {
    serviceType=$(helm template ${RELEASE_NAME} . --set service.type=LoadBalancer | yq 'select(.kind == "Service") | .spec.type' | tr -d '"')
    [ "$serviceType" = "LoadBalancer" ]
}

@test "Service adds custom annotations when provided" {
    annotation=$(helm template ${RELEASE_NAME} . --set service.annotations.custom\\.annotation=value | \
        yq 'select(.kind == "Service") | .metadata.annotations."custom.annotation"' | tr -d '"')
    [ "$annotation" = "value" ]
}

# PVC tests
@test "Helm template generates PersistentVolumeClaim" {
    run bash -c "helm template ${RELEASE_NAME} . | grep 'kind: PersistentVolumeClaim'"
    [ "$status" -eq 0 ]
}

@test "PVC has default storage size of 5Gi" {
    storage=$(helm template ${RELEASE_NAME} . | yq 'select(.kind == "PersistentVolumeClaim") | .spec.resources.requests.storage' | tr -d '"')
    [ "$storage" = "5Gi" ]
}

@test "PVC has ReadWriteOnce access mode" {
    helm template ${RELEASE_NAME} . | yq -e 'select(.kind == "PersistentVolumeClaim") | .spec.accessModes[] | select(. == "ReadWriteOnce")' > /dev/null
}

@test "PVC is not created when persistence disabled" {
    count=$(helm template ${RELEASE_NAME} . --set persistence.enabled=false | yq 'select(.kind == "PersistentVolumeClaim")' | wc -l)
    [ "$count" -eq 0 ]
}

@test "PVC sets storage class when specified" {
    storageClass=$(helm template ${RELEASE_NAME} . --set persistence.storageClass=fast-ssd | yq 'select(.kind == "PersistentVolumeClaim") | .spec.storageClassName' | tr -d '"')
    [ "$storageClass" = "fast-ssd" ]
}

# Ingress tests
@test "Ingress is not created by default" {
    count=$(helm template ${RELEASE_NAME} . | yq 'select(.kind == "Ingress")' | wc -l)
    [ "$count" -eq 0 ]
}

@test "Ingress is created when enabled" {
    run bash -c "helm template ${RELEASE_NAME} . --set ingress.enabled=true | grep 'kind: Ingress'"
    [ "$status" -eq 0 ]
}

@test "Ingress sets host when provided" {
    host=$(helm template ${RELEASE_NAME} . --set ingress.enabled=true --set ingress.hosts[0].host=meerkat.example.com --set ingress.hosts[0].paths[0].path=/ | \
        yq 'select(.kind == "Ingress") | .spec.rules[0].host' | tr -d '"')
    [ "$host" = "meerkat.example.com" ]
}

# HTTPRoute tests
@test "HTTPRoute is not created by default" {
    count=$(helm template ${RELEASE_NAME} . | yq 'select(.kind == "HTTPRoute")' | wc -l)
    [ "$count" -eq 0 ]
}

@test "HTTPRoute is created when enabled" {
    run bash -c "helm template ${RELEASE_NAME} . --set httpRoute.enabled=true | grep 'kind: HTTPRoute'"
    [ "$status" -eq 0 ]
}
