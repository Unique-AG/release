# `image-pull-secret`

> [!TIP]
> Unique generally encourages to pull images using machine identities (as example from Azure: [Authenticate with Azure Container Registry (ACR) from Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/cluster-container-registry-integration?tabs=azure-cli)) over using username and password.

For the cases where you need to pull images from a registry using a username and password, you can use this chart to create a Kubernetes secret in an easy manner.