# Rancher

> Rancher is a Kubernetes management tool to deploy and run clusters anywhere and on any provider.
>
> Rancher can provision Kubernetes from a hosted provider, provision compute nodes and then install Kubernetes onto
> them, or import existing Kubernetes clusters running anywhere.
>
> Rancher adds significant value on top of Kubernetes, first by centralizing authentication and role-based access
> control (RBAC) for all of the clusters, giving global admins the ability to control cluster access from one location.
>
> It then enables detailed monitoring and alerting for clusters and their resources, ships logs to external providers,
> and integrates directly with Helm via the Application Catalog. If you have an external CI/CD system, you can plug it
> into Rancher, but if you don't, Rancher even includes Fleet to help you automatically deploy and upgrade workloads.
>
> Rancher is a complete container management platform for Kubernetes, giving you the tools to successfully run
> Kubernetes anywhere.

## Documentation

| description       | link                                    |
|-------------------|-----------------------------------------|
| Rancher docs root | https://docs.ranchermanager.rancher.io/ |

## Environment Variables

Here you'll find a list of rancher environment variables that I've found useful:

| name                 | default                   | description                                                                                                            |
|----------------------|---------------------------|------------------------------------------------------------------------------------------------------------------------|
| `IMAGE_REPO`         | rancher                   | the repository to use when pulling images                                                                              |
| `CATTLE_AGENT_IMAGE` | rancher/rancher-agent:dev | the agent image to instruct the cluster being registered to the rancher server to use (useful when testing dev images) |
| `SSL_CERT_DIR`       | /etc/kubernetes/ssl/certs | the directory to store and look for ssl certs                                                                          |