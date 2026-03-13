# Helm Charts Repository

A collection of Helm charts

## Available Charts

- [its-mytabs](charts/its-mytabs/) - Music notation and tab management application
- [silverbullet](charts/silverbullet/) - Modern note-taking and personal knowledge management system

## Artifacthub links

- [its-mytabs](https://artifacthub.io/packages/helm/stone/its-mytabs)
- [silverbullet](https://artifacthub.io/packages/helm/stone/silverbullet)

## Usage

### Adding the Helm Repository

```bash
helm repo add stone https://stone.github.io/helm-charts
helm repo update
```

### Installing a Chart

```bash
# Install its-mytabs chart
helm install my-release stone/its-mytabs
helm install my-release stone/silverbullet

# Install with custom values
helm install my-release stone/its-mytabs -f values.yaml

# Install specific version
helm install my-release stone/its-mytabs --version 0.1.0
```

### Searching Available Charts

```bash
helm search repo stone
```

