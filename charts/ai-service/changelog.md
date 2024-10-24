# Changelog `ai-service`

## [1.0.6]
- Adjust the persistentVolumeClaim (PVC) to use its default name and configure the MountVolume in initContainers with readOnly set to false by default

## [1.0.5]
- Add volumes, PVC volumes, and emptyDir volumes in deployment

## [1.0.4]
- Add sidecar initContainers and volumes

## [1.0.3]
- Fix key vault binding bug in `apps/v1#Deployment`..

## [1.0.2]
- Fix render bug in `secrets-store.csi.x-k8s.io/v1#SecretProviderClass`.

## [1.0.1]
- Updates `secrets-store.csi.x-k8s.io/v1#SecretProviderClass` definition to leverage `userAssignedIdentityID` and `useVMManagedIdentity`.

## [1.0.0]
Inception of the chart as successor of the `python/charts/common` chart previously published by Unique.
This chart is feature-par and equal to the `python/charts/common` chart version `1.1.0`.