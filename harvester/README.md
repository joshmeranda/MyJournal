# Harvester

> Harvester is an open-source [hyper-converged infrastructure](https://en.wikipedia.org/wiki/Hyper-converged_infrastructure)
> (HCI) software built on Kubernetes. It is an open alternative to using a proprietary HCI stack that incorporates the
> design and ethos of [Cloud Native Computing](https://en.wikipedia.org/wiki/Cloud_native_computing).

## Documentation

| description        | link                              |
|--------------------|-----------------------------------|
| harvester doc root | https://docs.harvesterhci.io/v1.0 |

## Running

Since Harvester is basically just an OS you can run it the same wya you would any other os. You can download the iso
from the harvester [releases](https://github.com/harvester/harvester/releases). For development, I usually just deploy
Harvester on a VM either with VirtualBox or Vagrant.

Ideally, you would want to deploy Harvester on a bare metal server, but I do not have anything lying around to use as a
Harvester machine.

### Virtual Machine

#### Vagrant

One important thing to note is that as Harvester grows, some versions of the `ipxe-examples` will not be compatible with
all harvester isos. For example, the latest commit tha run the `v1.0.3` iso is tagged with `v1.0`.

## Yq

Many of the scripts in harvester rely on `yq` to query and modify yaml files. To get the version used by harvester run
the following command (pulled from
[this line](https://github.com/harvester/harvester/blob/dc6a30894d63a07ba8b6db5433a7054f71445fde/Dockerfile.dapper#L22)
in harvester):

```sh
GO111MODULE=on go install github.com/mikefarah/yq/v4@v4.6.0
```