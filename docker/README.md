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

## Force Removing Containers

In most situations it is simple and easy to stop and remove a container with `docker container stop <id> && docker
container rm <id>` but sometimes the damn container just won't stop or is taking too long, and I'm too impatient to sit
it out at 03:00. In these cases you want to use 'docker container rm --force' which will:

> The main process inside the container referenced under the link redis will receive SIGKILL, then the container will be
> removed.

This is usually fine, but sometimes you might end up with zombie processes in the docker container which are not cleaned
up correctly. [Docker and the PID 1 zombie reaping problem](https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/)
does a good job describing this problem.

### Lingering Zombies After Force Remove

Say I have a Dockerfile with creates an image to sleep infinitely:

```shell
FROM ubuntu:latest

CMD ['bash', '-c', 'sleep inf']
```

After running this image I can view the running processes with `ps` with
`305e812abc468e2495a2756398a2cc167f64c64e2f6de835b683faab546d8c24` being the container id:

```shell
$ ps -e -o pid,comm,cgroup | grep "/docker/305e812abc468e2495a2756398a2cc167f64c64e2f6de835b683faab546d8c24"
11487 sh              12:hugetlb:/docker/305e812abc468e2495a2756398a2cc167f64c64e2f6de835b683faab546d8c24,11:freezer:/docker/305e812abc468e2495a2756398a2cc167f64c64e2f6de835b683faab546d8c24,10:blkio:/docker/305e812abc468e2495a2756398a2cc167f64c64e2f6de835b683faab546d8c24,9:perf_event:/docker/305e812abc468e2495a2756398a2cc167f64c64e2f6de835b683faab546d8c24,8:cpu,cpuacct:/docker/305e812abc468e2495a2756398a2cc167f64c64e2f6de835b683faab546d8c24,7:rdma:/docker/305e812abc468e2495a2756398a2cc167f64c64e2f6de835b683faab546d8c24,6:net_cls,net_prio:/docker/305e812abc468e2495a2756398a2cc167f64c64e2f6de835b683faab546d8c24,5:devices:/docker/305e812abc468e2495a2756398a2cc167f64c64e2f6de835b683faab546d8c24,4:cpuset:/docker/305e812abc468e2495a2756398a2cc167f64c64e2f6de835b683faab546d8c24,3:pids:/docker/305e812abc468e2495a2756398a2cc167f64c64e2f6de835b683faab546d8c24,2:memory:/docker/305e812abc468e2495a2756398a2cc167f64c64e2f6de835b683faab546d8c24,1:name=systemd:/docker/305e812abc468e2495a2756398a2cc167f64c64e2f6de835b683faab546d8c24,0::/docker/305e812abc468e2495a2756398a2cc167f64c64e2f6de835b683faab546d8c24
11540 sleep           12:hugetlb:/docker/305e812abc468e2495a2756398a2cc167f64c64e2f6de835b683faab546d8c24,11:freezer:/docker/305e812abc468e2495a2756398a2cc167f64c64e2f6de835b683faab546d8c24,10:blkio:/docker/305e812abc468e2495a2756398a2cc167f64c64e2f6de835b683faab546d8c24,9:perf_event:/docker/305e812abc468e2495a2756398a2cc167f64c64e2f6de835b683faab546d8c24,8:cpu,cpuacct:/docker/305e812abc468e2495a2756398a2cc167f64c64e2f6de835b683faab546d8c24,7:rdma:/docker/305e812abc468e2495a2756398a2cc167f64c64e2f6de835b683faab546d8c24,6:net_cls,net_prio:/docker/305e812abc468e2495a2756398a2cc167f64c64e2f6de835b683faab546d8c24,5:devices:/docker/305e812abc468e2495a2756398a2cc167f64c64e2f6de835b683faab546d8c24,4:cpuset:/docker/305e812abc468e2495a2756398a2cc167f64c64e2f6de835b683faab546d8c24,3:pids:/docker/305e812abc468e2495a2756398a2cc167f64c64e2f6de835b683faab546d8c24,2:memory:/docker/305e812abc468e2495a2756398a2cc167f64c64e2f6de835b683faab546d8c24,1:name=systemd:/docker/305e812abc468e2495a2756398a2cc167f64c64e2f6de835b683faab546d8c24,0::/docker/305e812abc468e2495a2756398a2cc167f64c64e2f6de835b683faab546d8c24
```

So you can clearly see that 2 processes have been created: `sh` and `sleep`. This is what I expected, but what happens
when I force kill the `sh` processes?

```shell
docker container rm --force 305e812abc468e2495a2756398a2cc167f64c64e2f6de835b683faab546d8c24
ps -e -o pid,comm,cgroup | grep "/docker/305e812abc468e2495a2756398a2cc167f64c64e2f6de835b683faab546d8c24"
```

You will notice that the output for `ps` is empty. The `sleep` process appears to have been killed along with the parent
`sh`. So I feel safe and secure in the knowledge that force removing containers is still bad (see the article above) I
don't have to worry too much about container zombies lingering past their container's lifetime.
