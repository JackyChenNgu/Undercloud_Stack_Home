#!/bin/bash

set -eux

### --start_docs
## Prepare images for deploying the overcloud
## ==========================================

## Prepare Your Environment
## ------------------------

## * Source in the undercloud credentials.
## ::

source /home/stack/stackrc




## * Upload images to glance.
## ::

openstack overcloud image upload    --http-boot=/var/lib/ironic/httpboot

## * List out all the available OpenStack flavors.
## ::

for i in `openstack flavor list -c Name  -f value`; do
    echo $i; openstack flavor show $i;
done || true



## * Register nodes with Ironic.
## ::

openstack overcloud node import instackenv.json







## * Introspect hardware attributes of nodes.
## ::

    
        openstack overcloud node introspect --all-manageable
        openstack overcloud node provide --all-manageable

    




### --stop_docs
