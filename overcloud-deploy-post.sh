#!/bin/sh

set -eux

### --start_docs
## Post overcloud deployment steps
## ===============================

## * Prepare Your Environment.
## ::

HOSTFILE=/etc/hosts

## * Source in the undercloud credentials.
## ::

. /home/stack/stackrc

## * Remove any old overcloud host entries from `/etc/hosts`.
## ::

sudo sed -i '/^## BEGIN OVERCLOUD HOSTS/,/^## END OVERCLOUD HOSTS/ d' $HOSTFILE

## * Add overcloud hosts to `/etc/hosts`.
## ::

cat <<EOF | sudo tee -a $HOSTFILE
## BEGIN OVERCLOUD HOSTS  #nodocs
$(openstack stack output show overcloud HostsEntry -f value -c output_value)

## END OVERCLOUD HOSTS    #nodocs
EOF

## * Create the `heat_stack_owner` role if it doesn't already exist.
## ::

if openstack stack output show overcloud EnabledServices \
        -f value -c output_value | grep -q keystone; then

    ## * Source in the overcloud credentials.
    ## ::

    . /home/stack/overcloudrc

    if ! openstack role show heat_stack_owner > /dev/null 2>&1; then
        openstack role create heat_stack_owner
        openstack role add --project admin --user admin heat_stack_owner
    fi
fi
### --stop_docs
