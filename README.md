# Helm Charts Repository

A collection of Helm charts

## Available Charts

- [its-mytabs](charts/its-mytabs/) - Music notation and tab management application

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

# Install with custom values
helm install my-release stone/its-mytabs -f values.yaml

# Install specific version
helm install my-release stone/its-mytabs --version 0.1.0
```

### Searching Available Charts

```bash
helm search repo stone
```

