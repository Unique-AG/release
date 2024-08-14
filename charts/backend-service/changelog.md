# Changelog `backend-service`

## [1.0.3]
- Adds support for `clusterInternalServiceSuffix` to override the default `.svc.cluster.local` service address suffix which is used to reach internal services in the cluster.

## [1.0.2]
- Enable **useVMManagedIdentity** in the SecretProviderClasses.

## [1.0.1]
- Fix indentation of volume mounts in `deployment.yaml`.

## [1.0.0]
Inception of the chart as successor of the `node/charts/common` chart previously published by Unique.
This chart is feature-par and equal to the `node/charts/common` chart version `1.3.0`.