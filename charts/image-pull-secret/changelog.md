# Changelog `image-pull-secret`

## [1.0.9]
Remove comments

## [1.0.8]
Set revisionHistoryLimit to 3 as default

## [1.0.7]
Add unittest and fix SecretProviderClass

## [1.0.6]
Change SecretProviderClass name

## [1.0.5]
Add revisionHistoryLimit in deployment

## [1.0.4]
Add a condition to stop deploying the empty secret if spc exists

## [1.0.3]
Fix spec.selector.matchLabels inconsistency

## [1.0.2]
Fix bugs while rendering the deployment and the secretProviderClass

## [1.0.1]
Add a secretProviderClass and a deployment to be able to create secrets

## [1.0.0]
Inception of the chart. Consult the [readme.md](./readme.md) to get started.