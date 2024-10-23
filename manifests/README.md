# Cluster Logging Collector Benchmarks

This is a collection of scripts, manifests and utilities for setting up and benchmarking the performance of
the collector component of the Red Hat Openshift Logging solution.  These tests make the following assumptions:

* The receiver is "unconstrainted", meaning it is oversized and will not impose back pressure
* The load and collection is isolated to a single node since this determines the characteristics of any one deployed collector

## Goals

The following are metrics of interest because of how they impact the performance of the collector

* Memory
* CPU
* Filehandles
* Length of log messages
* Total log bytes collected
* Total log bytes sent
* Number of log events discarded
* Number of log events missed

# Running Tests

## Preparation
1. [Prep](./scripts/prep-cluster) the cluster
1. Deploy an Openshift cluster
1. Deploy the cluster-logging-operator
1. [Deploy](./scripts/deploy-grafana) an instance of grafana and the collection dashboard

## Deploy an Application Load

The application load is created by deploying a set of log generators that are isolated to the same node as the collector.
The [manifests](manifests/log-generator) directory includes deployments which allow deploying generators based on the following:

`<tot_loaders>_loaders_<cumulative_rate>`

* `tot_loaders`: is the total number of loaders deployed (e.g. 0100 is 100)
* `cumulative_rate`: is the sum total rate of all loaders deployed (e.g. 5000_lps)

For example, [0100_loaders_5000_lps](manifests/log-generator/overlays/0100_loaders_5000_lps) will deploy 100 log generators each producing 50 lines per sec.

Deploy the desired log generators by:

```
oc -k apply manifests/log-generator/overlays/0100_loaders_5000_lps
```

## Deploy a Receiver

```
oc -k apply manifests/receiver-otlp/base
```

## Deploy the Collector

Deploy the collector which matches the receiver

```
oc -k apply manifests/clusterlogforwarder/overlays/receiver-otlp
```