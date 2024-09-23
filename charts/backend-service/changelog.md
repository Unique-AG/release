# Changelog `backend-service`

## [1.1.0]
- All workloads now support a new `envVars` list as part of the `values.yaml`
    + Compared to `env`, which is a flat map, this list allows for more complex environment variable definitions as the native Kubernetes Specs support them.
    + Example
      ```
      envVars:
      - name: NAME_OF_ENV
        valueFrom:
          secretKeyRef:
            key: ENV_VALUE
            name: my-secret
      ```
- Improved documentation of all environment variable related settings in `values.yaml`

## [1.0.12]
- Enable initContainers/sideContainers

## [1.0.11]
- Enable useVMManagedIdentity in the SecretProviderClasses hooks and add external secrets in migration

## [1.0.10]
- Extends the charts setup (no functionality change) to include [`helm-unittest`](https://github.com/helm-unittest/helm-unittest) to avoid or mitigate further regressions.

## [1.0.9]
- Quick fix to end external secrets loop

## [1.0.8]
- Add external-secrets, Edit deployment to integrate external-secrets

## [1.0.7]
- Remove typo (unneeded `$` character) from `/public`, `tyk.tyk.io/v1alpha1.ApiDefinition`

## [1.0.6]
- Removes unneeded properties from the `tyk.tyk.io/v1alpha1.ApiDefinition` used for the `/public` API.

## [1.0.5]
- Remove typo (unneeded `$` character) from `tyk.tyk.io/v1alpha1.ApiDefinition`

## [1.0.4]
- Fix bug for useVMManagedIdentity and usePodIdentity quote issue

## [1.0.3]
- Adds support for `clusterInternalServiceSuffix` to override the default `.svc.cluster.local` service address suffix which is used to reach internal services in the cluster.

## [1.0.2]
- Enable **useVMManagedIdentity** in the SecretProviderClasses.

## [1.0.1]
- Fix indentation of volume mounts in `deployment.yaml`.

## [1.0.0]
Inception of the chart as successor of the `node/charts/common` chart previously published by Unique.
This chart is feature-par and equal to the `node/charts/common` chart version `1.3.0`.