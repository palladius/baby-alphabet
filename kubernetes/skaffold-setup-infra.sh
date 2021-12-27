#!/bin/bash

# this should be repeatable :) with UP and down

source .env

IPNAME="ajalphabet-skaff-ip"

_create_skaffold() {
    IP="$1"
    yellow Creating Skaffold YAML for AjAlphabet IP address.. 
cat << EOF > aj-alphabet-skaff/ajalphabet-service-staticip.yaml
# Scopiazzaed from https://cloud.google.com/kubernetes-engine/docs/tutorials/configuring-domain-name-static-ip
apiVersion: v1
kind: Service
metadata:
  name: helloweb
  labels:
    app: hello
spec:
  selector:
    app: hello
    tier: web
  ports:
  - port: 80
    targetPort: 8080
  type: LoadBalancer
  loadBalancerIP: "$IP"
EOF
}

infra_up() {

    echo Will take a while to get it up and running. Will start in RESERVED status
    gcloud compute addresses create $IPNAME --region $REGION
    IP=`gcloud compute addresses describe $IPNAME --region $REGION | grep address: |cut -f 2 -d:` 
    if echo $IP | fgrep . ; then
        _create_skaffold $IP
    else
        fatal Cant access its IP. Might have to wait a bit. IP=$IP
    fi




}



yellow TODO add UP and DOWN. For now only UP.
infra_up