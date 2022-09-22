# Docker

How Docker describes itself:
> Docker is an open platform for developing, shipping, and running applications. Docker enables you to separate your
> applications from your infrastructure so you can deliver software quickly. With Docker, you can manage your
> infrastructure in the same ways you manage your applications. By taking advantage of Docker’s methodologies for
> shipping, testing, and deploying code quickly, you can significantly reduce the delay between writing code and running
> it in production.

How I describe docker:
> Docker makes containers go brrrrr

## Documentation

| description          | link                                              |
|----------------------|---------------------------------------------------|
| reference docs       | https://docs.docker.com/reference/                |
| dockerfile reference | https://docs.docker.com/engine/reference/builder/ |

## Ls Filters

Several commands like `docker image ls` and `docker container ls` accept a `-f --filter` argument. Below you will find a
table of commands that take the `-f --filter` option, and a link to a reference describing the available options:

| command               | filter reference link                                                                                                     |
|-----------------------|---------------------------------------------------------------------------------------------------------------------------|
| `docker container ls` | https://docs.docker.com/engine/reference/commandline/ps/                                                                  |
| `docker image ls`     | https://github.com/moby/moby/blob/10c0af083544460a2ddc2218f37dc24a077f7d90/docs/reference/commandline/images.md#filtering |

## Running Docker as Non-Superuser

The [post-install docs](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user)
describe this, but I can never remember where, so I'm putting this here.

Simply put you just need to add your user to the `docker` group, than hack away!

```bash
sudo groupadd docker
sudo usermod -aG docker $USER

# worth a shot, but you may need to logout and login or even reboot
newgrp docker

# run docker
docker run hello-world
```

I will say that this is probably never a good idea, but fine for a local dev machine or for personal use. Docker has
this to say:

> The docker group grants privileges equivalent to the root user. For details on how this impacts security in your
> system, see [Docker Daemon Attack Surface](https://docs.docker.com/engine/security/#docker-daemon-attack-surface).