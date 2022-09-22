# Elasticsearch

> Elasticsearch is a distributed, RESTful search and analytics engine capable of addressing a growing number of use
> cases. As the heart of the Elastic Stack, it centrally stores your data for lightning fast search, fine‑tuned
> relevancy, and powerful analytics that scale with ease.

## Documentation

| description            | link                                                                                     |
|------------------------|------------------------------------------------------------------------------------------|
| elasticsearch doc root | https://www.elastic.co/guide/en/elasticsearch/reference/current/elasticsearch-intro.html |
| elasticsearch setup    | https://www.elastic.co/guide/en/elasticsearch/reference/current/setup.html               |

## Deploying

If running elastic search on your local machine, make sure that you have enough virtual memory to run. To do this you
can run: `sysctl vm.max_map_count` and ensure the following value if >= 262144. If you don't you should see an error in
the logs:

```text
bootstrap check failure [1] of [1]: max virtual memory areas vm.max_map_count [262140] is too low, increase to at least [262144]
```

To resolve you just need to modify the `sysctl` configurations. Fist edit `/etc/sysctl.conf` and set `vm.max_map_count=262144`:

```text
# this is a simple using the default sysctl.conf from my system plus vm.max_map_count
#
####
#
# /etc/sysctl.conf is meant for local sysctl settings
#
# sysctl reads settings from the following locations:
#   /boot/sysctl.conf-<kernelversion>
#   /lib/sysctl.d/*.conf
#   /usr/lib/sysctl.d/*.conf
#   /usr/local/lib/sysctl.d/*.conf
#   /etc/sysctl.d/*.conf
#   /run/sysctl.d/*.conf
#   /etc/sysctl.conf
#
# To disable or override a distribution provided file just place a
# file with the same name in /etc/sysctl.d/
#
# See sysctl.conf(5), sysctl.d(5) and sysctl(8) for more information
#
####
fs.inotify.max_user_watches = 524288
vm.max_map_count=262144
```

Then load the changes with `sysctl -p`. You should see that `vm.max_map_count` has now been set.

### Deploying in Docker

The easiest way to test with Elasticsearch is to deploy it on you local system using `docker`. To do this you can follow
[this tutorial](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html). I find that it is a bit
overkill. We don't necessarily need to create a network *just* to test an app that uses Elasticsearch. It's also a bit
annoying to deal with authentication if we're just doing a proof-of-concept.

So to simplify all of this you can deploy Elasticsearch with this command:

```shell
docker run --name elasticsearch -p 9200:9200 -p 9300:9300 -e xpack.security.enabled=false -e node.name=es01 -it docker.elastic.co/elasticsearch/elasticsearch:6.8.23
```

You can view more about the different security settings here: <https://www.elastic.co/guide/en/elasticsearch/reference/current/security-settings.html>