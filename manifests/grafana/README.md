# grafana

This directory contains an example configuration to install Grafana 10 to be used with an  incluster OpenShift Prometheus instance.

There is currently only one variant "ocp-oauth" which configures Grafana to use the OpenShift OAuth service for authentication.

## ocp-oauth Overlay

Following are configuration values that need to be set based on the cluster:

- `CLUSTER_ROUTES_BASE` in `kustomization.yaml`, based on the DNS name of the cluster

For example, your cluster domain (the part after `.apps.` in routes) is `my-cluster.devcluster.openshift.com` then the following configuration values would be correct:

```plain
CLUSTER_ROUTES_BASE=my-cluster.devcluster.openshift.com
```

Once the configuration values have been set in the files, the configuration can be applied using:

```bash
oc apply -k overlays/ocp-auth/
```

The configuration creates a `grafana` deployment and route in the `openshift-monitoring` namespace reachable using `https://grafana-openshift-monitoring.apps.${CLUSTER_ROUTES_BASE}/`.
