# Prometheus

> Prometheus is an open-source systems monitoring and alerting toolkit originally built at SoundCloud. Since its
> inception in 2012, many companies and organizations have adopted Prometheus, and the project has a very active
> developer and user community. It is now a standalone open source project and maintained independently of any company.
> To emphasize this, and to clarify the project's governance structure, Prometheus joined the Cloud Native Computing
> Foundation in 2016 as the second hosted project, after Kubernetes.
>
> Prometheus collects and stores its metrics as time series data, i.e. metrics information is stored with the timestamp
> at which it was recorded, alongside optional key-value pairs called labels.
>
> For more elaborate overviews of Prometheus, see the resources linked from the media section.

## Documentation

| description | link                                              |
|-------------|---------------------------------------------------|
| overview    | https://prometheus.io/docs/introduction/overview/ |
| overview    | https://prometheus.io/docs/introduction/overview/ |

## Remote Read

<https://prometheus.io/docs/prometheus/latest/querying/remote_read_api/>

<https://prometheus.io/blog/2019/10/10/remote-read-meets-streaming/>

## Remote Write

<https://prometheus-community.github.io/helm-charts>

## Prometheus Operator

<https://prometheus-operator.dev/>

```shell
git clone git@github.com:prometheus-community/helm-charts.git prometheus-helm-charts
cd prometheus-helm-charts/charts/prometheus
helm install --create-namespace --namespace monitoring promehtues-operator .
```