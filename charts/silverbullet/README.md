# SilverBullet Helm Chart

A Helm chart for deploying [SilverBullet](https://silverbullet.md), a modern, self-contained note-taking and personal knowledge management system.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure for persistence

## Installing the Chart

To install the chart with the release name `my-silverbullet`:

```bash
helm install my-silverbullet .
```

Or from the repository root:

```bash
helm install my-silverbullet ./charts/silverbullet
```

## Uninstalling the Chart

To uninstall/delete the `my-silverbullet` deployment:

```bash
helm delete my-silverbullet
```

## Configuration

The following table lists the configurable parameters of the SilverBullet chart and their default values.

### General Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of SilverBullet replicas | `1` |
| `image.repository` | SilverBullet image repository | `ghcr.io/silverbulletmd/silverbullet` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `image.tag` | Image tag (overrides chart appVersion) | `""` |
| `nameOverride` | Override chart name | `""` |
| `fullnameOverride` | Override full release name | `""` |

### Service Account

| Parameter | Description | Default |
|-----------|-------------|---------|
| `serviceAccount.create` | Create service account | `true` |
| `serviceAccount.annotations` | Service account annotations | `{}` |
| `serviceAccount.name` | Service account name | `""` |

### Security

| Parameter | Description | Default |
|-----------|-------------|---------|
| `serviceAccount.automount` | Automount service account token | `false` |
| `podSecurityContext.runAsUser` | Pod security context runAsUser | `1000` |
| `podSecurityContext.runAsGroup` | Pod security context runAsGroup | `1000` |
| `podSecurityContext.runAsNonRoot` | Run as non-root user | `true` |
| `podSecurityContext.fsGroup` | Pod security context fsGroup | `1000` |
| `podSecurityContext.fsGroupChangePolicy` | fsGroup change policy | `"OnRootMismatch"` |
| `podSecurityContext.seccompProfile.type` | Seccomp profile type | `RuntimeDefault` |
| `securityContext.allowPrivilegeEscalation` | Allow privilege escalation | `false` |
| `securityContext.runAsNonRoot` | Run as non-root user | `true` |
| `securityContext.runAsUser` | Container runAsUser | `1000` |
| `securityContext.runAsGroup` | Container runAsGroup | `1000` |
| `securityContext.readOnlyRootFilesystem` | Read-only root filesystem | `true` |
| `securityContext.capabilities.drop` | Dropped capabilities | `["ALL"]` |
| `securityContext.seccompProfile.type` | Container seccomp profile | `RuntimeDefault` |

### Network Policy

| Parameter | Description | Default |
|-----------|-------------|---------|
| `networkPolicy.enabled` | Enable NetworkPolicy | `false` |
| `networkPolicy.ingress` | Ingress rules | See values.yaml |
| `networkPolicy.egress` | Egress rules | See values.yaml |

### Service

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Kubernetes service type (ClusterIP, NodePort, LoadBalancer) | `ClusterIP` |
| `service.port` | Service port | `3000` |
| `service.nodePort` | NodePort to use when service.type is NodePort | `""` |
| `service.annotations` | Service annotations | `{}` |
| `service.labels` | Additional service labels | `{}` |

### Ingress

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.hosts` | Ingress hosts configuration | `[{host: "silverbullet.local", paths: [{path: "/", pathType: "Prefix"}]}]` |
| `ingress.tls` | Ingress TLS configuration | `[]` |

### Gateway API

Gateway API is a modern alternative to Ingress. Requires Gateway API CRDs to be installed.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `gateway.enabled` | Enable Gateway API resources | `false` |
| `gateway.existingGateway` | Name of existing Gateway to attach to | `""` |
| `gateway.gatewayClassName` | Gateway class name (when creating new Gateway) | `""` |
| `gateway.annotations` | Gateway annotations | `{}` |
| `gateway.labels` | Gateway labels | `{}` |
| `gateway.listeners` | Gateway listeners configuration | `[{name: "http", port: 80, protocol: "HTTP"}]` |
| `gateway.httpRoute.annotations` | HTTPRoute annotations | `{}` |
| `gateway.httpRoute.labels` | HTTPRoute labels | `{}` |
| `gateway.httpRoute.hostnames` | HTTPRoute hostnames | `["silverbullet.local"]` |
| `gateway.httpRoute.rules` | HTTPRoute rules configuration | `[{matches: [{path: {type: "PathPrefix", value: "/"}}]}]` |

### Resources

| Parameter | Description | Default |
|-----------|-------------|---------|
| `resources.limits.cpu` | CPU limit | `500m` |
| `resources.limits.memory` | Memory limit | `512Mi` |
| `resources.requests.cpu` | CPU request | `100m` |
| `resources.requests.memory` | Memory request | `128Mi` |

### Persistence

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.enabled` | Enable persistence | `true` |
| `persistence.existingClaim` | Use existing PVC | `""` |
| `persistence.storageClass` | Storage class | `""` |
| `persistence.accessMode` | Access mode | `ReadWriteOnce` |
| `persistence.size` | Storage size | `5Gi` |

### SilverBullet Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `silverbullet.auth.username` | Authentication username | `""` |
| `silverbullet.auth.password` | Authentication password | `""` |
| `silverbullet.auth.token` | Bearer token for authentication | `""` |
| `silverbullet.auth.existingSecret` | Use existing secret for auth | `""` |
| `silverbullet.indexPage` | Default page to load | `"index"` |
| `silverbullet.readOnly` | Enable read-only mode | `false` |
| `silverbullet.httpLogging` | Enable HTTP request logging | `false` |
| `silverbullet.metrics.enabled` | Enable Prometheus metrics | `false` |
| `silverbullet.metrics.port` | Metrics port | `9090` |

## Example: Installing with Custom Values

Create a `values.yaml` file:

```yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: notes.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: silverbullet-tls
      hosts:
        - notes.example.com

silverbullet:
  auth:
    username: admin
    password: your-secure-password

persistence:
  size: 10Gi
  storageClass: fast-ssd

resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 200m
    memory: 256Mi
```

Install the chart:

```bash
helm install my-silverbullet . -f values.yaml
```

### Authentication (REQUIRED for Production)

**IMPORTANT**: By default, SilverBullet runs without authentication, which is
not recommended for production use. Always set authentication credentials:

```yaml
silverbullet:
  auth:
    username: your-username
    password: your-secure-password
```

Or use an existing Kubernetes secret (recommended):

```bash
kubectl create secret generic silverbullet-auth \
  --from-literal=sb-user='username:password'
```

```yaml
silverbullet:
  auth:
    existingSecret: silverbullet-auth
```

## Links

- [SilverBullet Documentation](https://silverbullet.md)
- [SilverBullet GitHub](https://github.com/silverbulletmd/silverbullet)
- [Docker Installation Guide](https://silverbullet.md/Install/Docker)
- [Configuration Reference](https://silverbullet.md/Install/Configuration)
