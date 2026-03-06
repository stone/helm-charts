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

# Deployment tests
@test "Helm template generates Deployment" {
    run bash -c "helm template ${RELEASE_NAME} . | grep 'kind: Deployment'"
    [ "$status" -eq 0 ]
}

@test "Deployment uses correct image" {
    local appVersion
    appVersion=$(yq '.appVersion' Chart.yaml)
    image=$(helm template ${RELEASE_NAME} . | yq 'select(.kind == "Deployment") | .spec.template.spec.containers[0].image')
    [ "$image" = "ghcr.io/silverbulletmd/silverbullet:${appVersion}" ]
}

@test "Deployment sets custom image tag" {
    image=$(helm template ${RELEASE_NAME} . --set image.tag=v1.0.0 | yq 'select(.kind == "Deployment") | .spec.template.spec.containers[0].image')
    [ "$image" = "ghcr.io/silverbulletmd/silverbullet:v1.0.0" ]
}

@test "Deployment has default replica count of 1" {
    replicas=$(helm template ${RELEASE_NAME} . | yq 'select(.kind == "Deployment") | .spec.replicas')
    [ "$replicas" -eq 1 ]
}

@test "Deployment mounts data volume at /space" {
    helm template ${RELEASE_NAME} . | yq -e 'select(.kind == "Deployment") | .spec.template.spec.containers[0].volumeMounts[] | select(.name == "data" and .mountPath == "/space")' > /dev/null
}

@test "Deployment sets SB_FOLDER environment variable" {
    helm template ${RELEASE_NAME} . | yq -e 'select(.kind == "Deployment") | .spec.template.spec.containers[0].env[] | select(.name == "SB_FOLDER" and .value == "/space")' > /dev/null
}

@test "Deployment sets auth environment when credentials provided" {
    helm template ${RELEASE_NAME} . --set silverbullet.auth.username=testuser --set silverbullet.auth.password=testpass | \
        yq -e 'select(.kind == "Deployment") | .spec.template.spec.containers[0].env[] | select(.name == "SB_USER")' > /dev/null
}

@test "Deployment sets security context for pod" {
    runAsUser=$(helm template ${RELEASE_NAME} . | yq 'select(.kind == "Deployment") | .spec.template.spec.securityContext.runAsUser')
    runAsGroup=$(helm template ${RELEASE_NAME} . | yq 'select(.kind == "Deployment") | .spec.template.spec.securityContext.runAsGroup')
    fsGroup=$(helm template ${RELEASE_NAME} . | yq 'select(.kind == "Deployment") | .spec.template.spec.securityContext.fsGroup')
    [ "$runAsUser" -eq 1000 ]
    [ "$runAsGroup" -eq 1000 ]
    [ "$fsGroup" -eq 1000 ]
}

@test "Deployment sets security context for container" {
    runAsUser=$(helm template ${RELEASE_NAME} . | yq 'select(.kind == "Deployment") | .spec.template.spec.containers[0].securityContext.runAsUser')
    readOnly=$(helm template ${RELEASE_NAME} . | yq 'select(.kind == "Deployment") | .spec.template.spec.containers[0].securityContext.readOnlyRootFilesystem')
    allowEscalation=$(helm template ${RELEASE_NAME} . | yq 'select(.kind == "Deployment") | .spec.template.spec.containers[0].securityContext.allowPrivilegeEscalation')
    [ "$runAsUser" -eq 1000 ]
    [ "$readOnly" = "true" ]
    [ "$allowEscalation" = "false" ]
}

@test "Deployment sets resource limits" {
    cpuLimit=$(helm template ${RELEASE_NAME} . | yq 'select(.kind == "Deployment") | .spec.template.spec.containers[0].resources.limits.cpu')
    memLimit=$(helm template ${RELEASE_NAME} . | yq 'select(.kind == "Deployment") | .spec.template.spec.containers[0].resources.limits.memory')
    [ "$cpuLimit" = "500m" ]
    [ "$memLimit" = "512Mi" ]
}

@test "Deployment enables metrics when configured" {
    helm template ${RELEASE_NAME} . --set silverbullet.metrics.enabled=true --set silverbullet.metrics.port=9090 | \
        yq -e 'select(.kind == "Deployment") | .spec.template.spec.containers[0].ports[] | select(.name == "metrics" and .containerPort == 9090)' > /dev/null
}

# Service tests
@test "Helm template generates Service" {
    run bash -c "helm template ${RELEASE_NAME} . | grep 'kind: Service'"
    [ "$status" -eq 0 ]
}

@test "Service has correct type ClusterIP by default" {
    serviceType=$(helm template ${RELEASE_NAME} . | yq 'select(.kind == "Service") | .spec.type')
    [ "$serviceType" = "ClusterIP" ]
}

@test "Service exposes port 3000" {
    port=$(helm template ${RELEASE_NAME} . | yq 'select(.kind == "Service") | .spec.ports[] | select(.name == "http") | .port')
    [ "$port" -eq 3000 ]
}

@test "Service exposes metrics port when enabled" {
    helm template ${RELEASE_NAME} . --set silverbullet.metrics.enabled=true --set silverbullet.metrics.port=9090 | \
        yq -e 'select(.kind == "Service") | .spec.ports[] | select(.name == "metrics" and .port == 9090)' > /dev/null
}

@test "Service sets NodePort type when configured" {
    serviceType=$(helm template ${RELEASE_NAME} . --set service.type=NodePort | yq 'select(.kind == "Service") | .spec.type')
    [ "$serviceType" = "NodePort" ]
}

@test "Service sets LoadBalancer type when configured" {
    serviceType=$(helm template ${RELEASE_NAME} . --set service.type=LoadBalancer | yq 'select(.kind == "Service") | .spec.type')
    [ "$serviceType" = "LoadBalancer" ]
}

@test "Service adds custom annotations when provided" {
    annotation=$(helm template ${RELEASE_NAME} . --set service.annotations.custom\\.annotation=value | \
        yq 'select(.kind == "Service") | .metadata.annotations."custom.annotation"')
    [ "$annotation" = "value" ]
}

# PVC tests
@test "Helm template generates PersistentVolumeClaim" {
    run bash -c "helm template ${RELEASE_NAME} . | grep 'kind: PersistentVolumeClaim'"
    [ "$status" -eq 0 ]
}

@test "PVC has default storage size of 5Gi" {
    storage=$(helm template ${RELEASE_NAME} . | yq 'select(.kind == "PersistentVolumeClaim") | .spec.resources.requests.storage')
    [ "$storage" = "5Gi" ]
}

@test "PVC has ReadWriteOnce access mode" {
    helm template ${RELEASE_NAME} . | yq -e 'select(.kind == "PersistentVolumeClaim") | .spec.accessModes[] | select(. == "ReadWriteOnce")' > /dev/null
}

@test "PVC is not created when persistence disabled" {
    count=$(helm template ${RELEASE_NAME} . --set persistence.enabled=false | yq 'select(.kind == "PersistentVolumeClaim")' | wc -l)
    [ "$count" -eq 0 ]
}

@test "PVC is not created when using existing claim" {
    count=$(helm template ${RELEASE_NAME} . --set persistence.existingClaim=my-existing-pvc | yq 'select(.kind == "PersistentVolumeClaim")' | wc -l)
    [ "$count" -eq 0 ]
}

@test "PVC sets storage class when specified" {
    storageClass=$(helm template ${RELEASE_NAME} . --set persistence.storageClass=fast-ssd | yq 'select(.kind == "PersistentVolumeClaim") | .spec.storageClassName')
    [ "$storageClass" = "fast-ssd" ]
}

# Secret tests
@test "Secret is not created by default" {
    count=$(helm template ${RELEASE_NAME} . | yq 'select(.kind == "Secret")' | wc -l)
    [ "$count" -eq 0 ]
}

@test "Secret is created when username and password provided" {
    run bash -c "helm template ${RELEASE_NAME} . --set silverbullet.auth.username=testuser --set silverbullet.auth.password=testpass | grep 'kind: Secret'"
    [ "$status" -eq 0 ]
}

@test "Secret is created when token provided" {
    run bash -c "helm template ${RELEASE_NAME} . --set silverbullet.auth.token=mytoken123 | grep 'kind: Secret'"
    [ "$status" -eq 0 ]
}

@test "Secret is not created when using existing secret" {
    count=$(helm template ${RELEASE_NAME} . --set silverbullet.auth.username=testuser --set silverbullet.auth.password=testpass --set silverbullet.auth.existingSecret=my-existing-secret | yq 'select(.kind == "Secret")' | wc -l)
    [ "$count" -eq 0 ]
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

@test "Ingress sets class name when specified" {
    className=$(helm template ${RELEASE_NAME} . --set ingress.enabled=true --set ingress.className=nginx | yq 'select(.kind == "Ingress") | .spec.ingressClassName')
    [ "$className" = "nginx" ]
}

@test "Ingress configures hosts" {
    host=$(helm template ${RELEASE_NAME} . --set ingress.enabled=true --set ingress.hosts[0].host=silverbullet.example.com --set ingress.hosts[0].paths[0].path=/ | \
        yq 'select(.kind == "Ingress") | .spec.rules[0].host')
    [ "$host" = "silverbullet.example.com" ]
}

# Gateway tests
@test "Gateway is not created by default" {
    count=$(helm template ${RELEASE_NAME} . | yq 'select(.kind == "Gateway")' | wc -l)
    [ "$count" -eq 0 ]
}

@test "HTTPRoute is not created by default" {
    count=$(helm template ${RELEASE_NAME} . | yq 'select(.kind == "HTTPRoute")' | wc -l)
    [ "$count" -eq 0 ]
}

@test "HTTPRoute is created when gateway enabled with existing gateway" {
    run bash -c "helm template ${RELEASE_NAME} . --set gateway.enabled=true --set gateway.existingGateway=existing-gateway | grep 'kind: HTTPRoute'"
    [ "$status" -eq 0 ]
}

@test "Gateway is created when gateway enabled without existing gateway" {
    run bash -c "helm template ${RELEASE_NAME} . --set gateway.enabled=true --set gateway.gatewayClassName=nginx --set gateway.listeners[0].name=http --set gateway.listeners[0].port=80 --set gateway.listeners[0].protocol=HTTP | grep 'kind: Gateway'"
    [ "$status" -eq 0 ]
}

@test "Gateway sets correct gateway class name" {
    className=$(helm template ${RELEASE_NAME} . --set gateway.enabled=true --set gateway.gatewayClassName=istio --set gateway.listeners[0].name=http --set gateway.listeners[0].port=80 --set gateway.listeners[0].protocol=HTTP | \
        yq 'select(.kind == "Gateway") | .spec.gatewayClassName')
    [ "$className" = "istio" ]
}

# NetworkPolicy tests
@test "NetworkPolicy is not created when disabled" {
    count=$(helm template ${RELEASE_NAME} . | yq 'select(.kind == "NetworkPolicy")' | wc -l)
    [ "$count" -eq 0 ]
}

@test "NetworkPolicy is created when enabled" {
    run bash -c "helm template ${RELEASE_NAME} . --set networkPolicy.enabled=true | grep 'kind: NetworkPolicy'"
    [ "$status" -eq 0 ]
}

@test "NetworkPolicy sets policy types" {
    helm template ${RELEASE_NAME} . --set networkPolicy.enabled=true | \
        yq -e 'select(.kind == "NetworkPolicy") | .spec.policyTypes[] | select(. == "Ingress")' > /dev/null
    helm template ${RELEASE_NAME} . --set networkPolicy.enabled=true | \
        yq -e 'select(.kind == "NetworkPolicy") | .spec.policyTypes[] | select(. == "Egress")' > /dev/null
}

# ServiceAccount tests
@test "ServiceAccount is created by default" {
    run bash -c "helm template ${RELEASE_NAME} . | grep 'kind: ServiceAccount'"
    [ "$status" -eq 0 ]
}

@test "ServiceAccount is not created when disabled" {
    count=$(helm template ${RELEASE_NAME} . --set serviceAccount.create=false | yq 'select(.kind == "ServiceAccount")' | wc -l)
    [ "$count" -eq 0 ]
}

@test "ServiceAccount disables automount by default for security" {
    automount=$(helm template ${RELEASE_NAME} . | yq 'select(.kind == "ServiceAccount") | .automountServiceAccountToken')
    [ "$automount" = "false" ]
}

@test "ServiceAccount can enable automount when needed" {
    automount=$(helm template ${RELEASE_NAME} . --set serviceAccount.automount=true | yq 'select(.kind == "ServiceAccount") | .automountServiceAccountToken')
    [ "$automount" = "true" ]
}
