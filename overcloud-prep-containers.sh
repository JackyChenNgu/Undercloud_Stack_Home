#!/bin/bash

set -eux

### --start_docs
## Prepare the undercloud for deploying the containerized compute node
## ===================================================================

## .. note:: In progress documentation is available at https://etherpad.openstack.org/p/tripleo-containers-work
## ::

## Prepare Your Environment
## ------------------------

## * Add an additional insecure registry if needed
## ::

PREPARE_ARGS=${PREPARE_ARGS:-"-e /usr/share/openstack-tripleo-heat-templates/environments/docker.yaml"}

## * Configure the /home/stack/containers-default-parameters.yaml, and
##   populate the docker registry. This is done automatically.
## ::

openstack tripleo container image prepare --verbose \
    --output-env-file /home/stack/containers-default-parameters.yaml \
    ${PREPARE_ARGS} \
    -e /home/stack/containers-prepare-parameter.yaml


echo "============================="
echo "Containers default parameters:"
cat /home/stack/containers-default-parameters.yaml
echo "============================="

## * Get the journal logs for docker
## ::

sudo journalctl -u docker > docker_journalctl.log

### --stop_docs
