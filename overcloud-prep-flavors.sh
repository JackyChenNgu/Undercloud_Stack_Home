#!/bin/bash

set -eux

### --start_docs
## Prepare flavors for deploying the overcloud
## ===========================================

## Prepare Your Environment
## ------------------------

## * Source in the undercloud credentials.
## ::

source /home/stack/stackrc

## Create flavors required for deployment
## --------------------------------------


## * Ensure oooq_control flavor does not exist before attempting to create a new one.

## ::

nova flavor-delete oooq_control > /dev/null 2>&1 || true

## .. note: We subtract one from the total disk size here to resolve problems
##    encountered in CI in which the available disk space on the virtual
##    nodes was slightly less than what we requested.

## ::

openstack flavor create --id auto \
    --ram 8192 \
    --disk $(( 50 - 1)) \
    --vcpus 2 \
    oooq_control
openstack flavor set \
    --property "cpu_arch"="x86_64" \
    --property "capabilities:boot_option"="local" \
    --property "capabilities:profile"="control" oooq_control \
    --property "resources:CUSTOM_BAREMETAL"="1" \
    --property "resources:DISK_GB"="0" \
    --property "resources:MEMORY_MB"="0" \
    --property "resources:VCPU"="0"


## * Ensure oooq_blockstorage flavor does not exist before attempting to create a new one.

## ::

nova flavor-delete oooq_blockstorage > /dev/null 2>&1 || true

## .. note: We subtract one from the total disk size here to resolve problems
##    encountered in CI in which the available disk space on the virtual
##    nodes was slightly less than what we requested.

## ::

openstack flavor create --id auto \
    --ram 8192 \
    --disk $(( 50 - 1)) \
    --vcpus 2 \
    oooq_blockstorage
openstack flavor set \
    --property "cpu_arch"="x86_64" \
    --property "capabilities:boot_option"="local" \
    --property "capabilities:profile"="blockstorage" oooq_blockstorage \
    --property "resources:CUSTOM_BAREMETAL"="1" \
    --property "resources:DISK_GB"="0" \
    --property "resources:MEMORY_MB"="0" \
    --property "resources:VCPU"="0"


## * Ensure oooq_compute flavor does not exist before attempting to create a new one.

## ::

nova flavor-delete oooq_compute > /dev/null 2>&1 || true

## .. note: We subtract one from the total disk size here to resolve problems
##    encountered in CI in which the available disk space on the virtual
##    nodes was slightly less than what we requested.

## ::

openstack flavor create --id auto \
    --ram 8192 \
    --disk $(( 50 - 1)) \
    --vcpus 2 \
    oooq_compute
openstack flavor set \
    --property "cpu_arch"="x86_64" \
    --property "capabilities:boot_option"="local" \
    --property "capabilities:profile"="compute" oooq_compute \
    --property "resources:CUSTOM_BAREMETAL"="1" \
    --property "resources:DISK_GB"="0" \
    --property "resources:MEMORY_MB"="0" \
    --property "resources:VCPU"="0"


## * Ensure oooq_objectstorage flavor does not exist before attempting to create a new one.

## ::

nova flavor-delete oooq_objectstorage > /dev/null 2>&1 || true

## .. note: We subtract one from the total disk size here to resolve problems
##    encountered in CI in which the available disk space on the virtual
##    nodes was slightly less than what we requested.

## ::

openstack flavor create --id auto \
    --ram 8192 \
    --disk $(( 50 - 1)) \
    --vcpus 2 \
    oooq_objectstorage
openstack flavor set \
    --property "cpu_arch"="x86_64" \
    --property "capabilities:boot_option"="local" \
    --property "capabilities:profile"="objectstorage" oooq_objectstorage \
    --property "resources:CUSTOM_BAREMETAL"="1" \
    --property "resources:DISK_GB"="0" \
    --property "resources:MEMORY_MB"="0" \
    --property "resources:VCPU"="0"


## * Ensure oooq_ceph flavor does not exist before attempting to create a new one.

## ::

nova flavor-delete oooq_ceph > /dev/null 2>&1 || true

## .. note: We subtract one from the total disk size here to resolve problems
##    encountered in CI in which the available disk space on the virtual
##    nodes was slightly less than what we requested.

## ::

openstack flavor create --id auto \
    --ram 8192 \
    --disk $(( 50 - 1)) \
    --vcpus 2 \
    oooq_ceph
openstack flavor set \
    --property "cpu_arch"="x86_64" \
    --property "capabilities:boot_option"="local" \
    --property "capabilities:profile"="ceph" oooq_ceph \
    --property "resources:CUSTOM_BAREMETAL"="1" \
    --property "resources:DISK_GB"="0" \
    --property "resources:MEMORY_MB"="0" \
    --property "resources:VCPU"="0"


### --stop_docs
