# silverbullet

![Version: 0.4.0](https://img.shields.io/badge/Version-0.4.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2.5.2](https://img.shields.io/badge/AppVersion-2.5.2-informational?style=flat-square)

A Helm chart for SilverBullet - a modern, self-contained note-taking and personal knowledge management system

**Homepage:** <https://silverbullet.md>

## Source Code

* <https://github.com/silverbulletmd/silverbullet>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| fullnameOverride | string | `""` |  |
| gateway.annotations | object | `{}` |  |
| gateway.enabled | bool | `false` |  |
| gateway.existingGateway | string | `""` |  |
| gateway.gatewayClassName | string | `""` |  |
| gateway.httpRoute.annotations | object | `{}` |  |
| gateway.httpRoute.hostnames[0] | string | `"silverbullet.local"` |  |
| gateway.httpRoute.labels | object | `{}` |  |
| gateway.httpRoute.rules[0].matches[0].path.type | string | `"PathPrefix"` |  |
| gateway.httpRoute.rules[0].matches[0].path.value | string | `"/"` |  |
| gateway.httpRoute.tls.enabled | bool | `false` |  |
| gateway.labels | object | `{}` |  |
| gateway.listeners[0].name | string | `"http"` |  |
| gateway.listeners[0].port | int | `80` |  |
| gateway.listeners[0].protocol | string | `"HTTP"` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"ghcr.io/silverbulletmd/silverbullet"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"silverbullet.local"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"Prefix"` |  |
| ingress.tls | list | `[]` |  |
| livenessProbe.failureThreshold | int | `3` |  |
| livenessProbe.httpGet.path | string | `"/"` |  |
| livenessProbe.httpGet.port | string | `"http"` |  |
| livenessProbe.initialDelaySeconds | int | `30` |  |
| livenessProbe.periodSeconds | int | `10` |  |
| livenessProbe.timeoutSeconds | int | `5` |  |
| nameOverride | string | `""` |  |
| networkPolicy.egress[0].ports[0].port | int | `53` |  |
| networkPolicy.egress[0].ports[0].protocol | string | `"UDP"` |  |
| networkPolicy.egress[0].to[0].namespaceSelector.matchLabels.name | string | `"kube-system"` |  |
| networkPolicy.enabled | bool | `false` |  |
| networkPolicy.ingress[0].from[0].namespaceSelector.matchLabels.name | string | `"ingress-nginx"` |  |
| networkPolicy.ingress[0].ports[0].port | int | `3000` |  |
| networkPolicy.ingress[0].ports[0].protocol | string | `"TCP"` |  |
| nodeSelector | object | `{}` |  |
| persistence.accessMode | string | `"ReadWriteOnce"` |  |
| persistence.annotations | object | `{}` |  |
| persistence.enabled | bool | `true` |  |
| persistence.size | string | `"5Gi"` |  |
| persistence.storageClass | string | `""` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podSecurityContext.fsGroup | int | `1000` |  |
| podSecurityContext.fsGroupChangePolicy | string | `"OnRootMismatch"` |  |
| podSecurityContext.runAsGroup | int | `1000` |  |
| podSecurityContext.runAsNonRoot | bool | `true` |  |
| podSecurityContext.runAsUser | int | `1000` |  |
| podSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| readinessProbe.failureThreshold | int | `3` |  |
| readinessProbe.httpGet.path | string | `"/"` |  |
| readinessProbe.httpGet.port | string | `"http"` |  |
| readinessProbe.initialDelaySeconds | int | `10` |  |
| readinessProbe.periodSeconds | int | `5` |  |
| readinessProbe.timeoutSeconds | int | `3` |  |
| replicaCount | int | `1` |  |
| resources.limits.cpu | string | `"500m"` |  |
| resources.limits.memory | string | `"512Mi"` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"128Mi"` |  |
| securityContext.allowPrivilegeEscalation | bool | `false` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.readOnlyRootFilesystem | bool | `true` |  |
| securityContext.runAsGroup | int | `1000` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| securityContext.runAsUser | int | `1000` |  |
| securityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| service.annotations | object | `{}` |  |
| service.labels | object | `{}` |  |
| service.nodePort | string | `""` |  |
| service.port | int | `3000` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.automount | bool | `false` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| silverbullet.auth.lockoutLimit | int | `10` |  |
| silverbullet.auth.lockoutTime | int | `60` |  |
| silverbullet.auth.password | string | `""` |  |
| silverbullet.auth.rememberMeHours | int | `168` |  |
| silverbullet.auth.token | string | `""` |  |
| silverbullet.auth.username | string | `""` |  |
| silverbullet.description | string | `"SilverBullet - Personal Knowledge Management"` |  |
| silverbullet.extraEnv | list | `[]` |  |
| silverbullet.extraEnvFrom | list | `[]` |  |
| silverbullet.httpLogging | bool | `false` |  |
| silverbullet.indexPage | string | `"index"` |  |
| silverbullet.logPush | bool | `false` |  |
| silverbullet.metrics.enabled | bool | `false` |  |
| silverbullet.metrics.port | int | `9090` |  |
| silverbullet.name | string | `"SilverBullet"` |  |
| silverbullet.readOnly | bool | `false` |  |
| silverbullet.shellBackend | string | `"local"` |  |
| silverbullet.shellWhitelist | string | `""` |  |
| silverbullet.spaceIgnore | string | `""` |  |
| silverbullet.urlPrefix | string | `""` |  |
| tolerations | list | `[]` |  |
| volumeMounts | list | `[]` |  |
| volumes | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
