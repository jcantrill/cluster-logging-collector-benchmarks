
.PHONY: echo
echo:
	echo "testing..."

.PHONY: setup
setup:
	./scripts/prep-cluster 
	./scripts/deploy-grafana
	echo "grafana route: $$(oc get route grafana -n openshift-monitoring | grep -o grafana-.*openshift\.com)"

AWS_PROFILE?=openshift-dev
AWS_ACCESS_KEY_ID?=$(shell aws configure get aws_access_key_id)
AWS_SECRET_ACCESS_KEY?=$(shell aws configure get aws_secret_access_key)
REGION?=us-east-1
LOKI_SECRET_NAME?=loki-s3
AWS_BUCKET_NAME?=$(shell whoami)-$(shell date +'%m%d')

.PHONY: setup-for-lokistack
setup-for-lokistack: create-s3-bucket setup-aws-secret

.PHONY: deploy-loki-operator
deploy-loki-operator:
	./scripts/deploy-loki-operator

.PHONY: deploy-lokistack
deploy-lokistack:
	oc apply -k manifests/receivers/loki_stack

.PHONY: setup-aws-secret
setup-aws-secret:
	oc -n openshift-logging create secret generic $(LOKI_SECRET_NAME) \
	--from-literal=region=$(REGION) \
	--from-literal=bucketnames=$(AWS_BUCKET_NAME) \
	--from-literal=access_key_id=$(AWS_ACCESS_KEY_ID) \
	--from-literal=access_key_secret=$(AWS_SECRET_ACCESS_KEY) \
	--from-literal=endpoint=https://s3.$(REGION).amazonaws.com

.PHONY: create-s3-bucket
create-s3-bucket:
	if aws s3api get-bucket-location --bucket $(AWS_BUCKET_NAME) > /dev/null 2>&1 ; then \
		echo -e "\n s3 bucket \"$(AWS_BUCKET_NAME)\" found"  ; \
	else \
		echo -e "\n creating s3 bucket: $(AWS_BUCKET_NAME)" ; \
		if [[ "$(REGION)" = "us-east-1" ]] ; then \
			aws s3api create-bucket --acl private --region $(REGION) --bucket $(AWS_BUCKET_NAME) ; \
		else \
			aws s3api create-bucket --acl private --region $(REGION) --bucket $(AWS_BUCKET_NAME) \
			--create-bucket-configuration LocationConstraint=$(REGION) ; \
		fi ; \
	fi

.PHONY: deploy-receiver
deploy-receiver:
	oc apply -k manifests/receivers/$(RECEIVER)

RECEIVER=$(error RECEIVER missing one of: $(shell ls manifests/clusterlogforwarder/overlays))
.PHONY: deploy-cluster-log-forwarder-to
deploy-cluster-log-forwarder-to:
	oc apply -k manifests/clusterlogforwarder/overlays/$(RECEIVER)

LPS=$(error LPS missing: Need lines per second)
SCALE=$(error SCALE missing: Need number of pods)
.PHONY: deploy-log-generator
deploy-log-generator:
	oc apply -k manifests/log-generator/overlays/$(LPS)_lps/$(SCALE)_loaders
