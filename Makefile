
.PHONY: echo
echo:
	echo "testing..."

.PHONY: setup
setup:
	./scripts/prep-cluster 
	./scripts/deploy-grafana
	echo "grafana route: $$(oc get route grafana -n openshift-monitoring | grep -o grafana-.*openshift\.com)"

.PHONY: deploy-receiver
deploy-receiver:
	oc apply -k manifests/receivers/$(RECEIVER)
.PHONY: deploy-cluster-log-forwarder-to
deploy-cluster-log-forwarder-to:
	oc apply -k manifests/clusterlogforwarder/overlays/receiver-$(RECEIVER)
