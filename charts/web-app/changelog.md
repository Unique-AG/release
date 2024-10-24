# Changelog `next/charts/web-app`

All notable changes to the `next/charts/web-app` will be documented in this file.

## [1.3.0] - 2024-10-23

### Added

- Supports `apiextensions.k8s.io/v1#HTTPRoute`s to accommodate for the next generation of Kubernetes Ingress, Load Balancing, and Service Mesh APIs.
  Refer to `.Values.httproute` for examples and instructions.
  💥 CRD's for `gateway.networking.k8s.io` must be present in the cluster in order for this to work.


## [1.2.0] - 2024-05-14

### Changed

- Support `.strategy.type` (defaults to `RollingUpdate`, keeping the same behavior as before) but allows now to set it to `Recreate` if needed.

## [1.1.0]

Changelog added.
