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
| `SSL_CERT_DIR`       | /etc/kubernetes/ssl/certs | the directory to store and look for ssl certs (I have had issues using this and doesn't seem to work as expected)      |

## Rancher with Custom Certs

It is possible to use custom certs when running rancher by mounting them under the `/etc/rancher/ssl/` directory. When
deploying rancher with `docker`, you just need to provide the mounts at runtime. For example, assuming you have created
the certs in a directory called `./certs`:

```shell
docker run --privelaged --restart=unless-stopped --publish 80:80 --publish 443:443 --name rancher \
           --mount "type=bind,source=./certs/cert.pem,target=/etc/rancher/ssl/cert.pem" \
           --mount "type=bind,source=./certs/key.pem,target=/etc/rancher/ssl/key.pem" \
           --mount "type=bind,source=./certs/ca.pem,target=/etc/rancher/ssl/cacerts.pem" \
           rancher/rancher:latest
```

To double check that rancher is using your certs, you can view it in the UI by visiting `Global Settings > cacerts >
Show cacerts`. The display value should match the file you mounted at `/etc/racnher/ssl/cacerts.pem`.

### Generating Self-Signed Certs

I typically use [superseb/omgwtfssl](https://github.com/superseb/omgwtfssl) when generating self-signed certs for
testing rancher.

```shell
docker run --volume "./certs:/certs" \
           --env CA_SUBJECT='Self Signed Cert' \
           --env CA_EXPIRE=1825 \
           --env SSL_EXPIRE=365 \
           --env SSL_SUBJECT="Launch Rancher Self-Signed" \
           --env SSL_IP="<local ip>" \
           superseb/omgwtfssl > /dev/null 2>&1
```

You can view more configuration options [here](https://github.com/superseb/omgwtfssl#advanced-usage).