#!/bin/bash

set -eux

### --start_docs
## Validate the overcloud deployment with tempest
## ==============================================

## Configure tempest
## -----------------

## * Clean up from any previous tempest run
## ::

# On doing tempest init workspace, it will create workspace directory
# as well as .workspace directory to store workspace information
# We need to delete .workspace directory otherwise tempest init failed
# to create tempest directory.
# We are doing this as sudo because tempest in containers create the files as
# root.


# Cloud Credentials
source /home/stack/overcloudrc

## Create Tempest resources
## ------------------------
## * For overcloud


## * Clean up network if it exists from previous run
## ::


for i in $(openstack floating ip list -c ID -f value)
do
    openstack floating ip unset --port $i
    openstack floating ip delete $i
done
for i in $(openstack router list -c ID -f value); do openstack router unset --external-gateway $i; done
for r in $(openstack router list -c ID -f value); do
    for p in $(openstack port list --router $r -c ID -f value); do
        openstack router remove subnet $r $p || true
    done
done
for i in $(openstack router list -c ID -f value); do openstack router delete $i; done
for i in $(openstack port list -c ID -f value); do openstack port delete $i; done
for i in $(openstack network list -c ID -f value); do openstack network delete $i; done


openstack network create public --external \
    --provider-network-type flat \
        --provider-physical-network datacentre

openstack subnet create ext-subnet \
    --allocation-pool \
    start=192.168.24.100,end=192.168.24.120 \
    --no-dhcp \
    --gateway 192.168.24.1 \
    --network public \
    --subnet-range 192.168.24.0/24


## * Ensure creator and Member role is present
## * Member role is needed for Heat tests.
## * creator role is needed for Barbican for running volume encryption tests.
## ::

openstack role show Member > /dev/null || openstack role create Member

openstack role show creator > /dev/null || openstack role create creator

## Install openstack-tempest
## -------------------------
## * Using git
## ::


echo "========= Note: Executing tempest via a container =========="

cat <<'EOF' > /home/stack/tempest_container.sh
# Set the exit status for the command
set -e

# Load rc file or os_cloud file

source /var/lib/tempest/overcloudrc

# Get the list of tempest/-plugins rpms installed within a tempest container
# It will be useful for debugging and making sure at what commit
# tempest/tempest plugins rpms are installed in the same.

rpm -qa | grep tempest

# Remove the existing tempest workspace
if [ -d /var/lib/tempest/tempest/etc ]; then
tempest workspace remove --name tempest --rmdir
fi

## Create Tempest Workspace
## ------------------------
## ::


# Create Tempest directory

mkdir /var/lib/tempest/tempest

# Create Tempest workspace
pushd /var/lib/tempest/tempest
tempest init /var/lib/tempest/tempest
popd

## Generate tempest configuration using python-tempestconf
## -------------------------------------------------------
## ::
export TEMPESTCONF="/usr/bin/discover-tempest-config"

# Get public net id

public_net_id=$(openstack network show public -f value -c id)
region_name=${OS_REGION_NAME:-'regionOne'}

# Generate Tempest Config file using python-tempestconf
# Notice aodh_plugin will be set to False if telemetry service is disabled
cd /var/lib/tempest/tempest
$TEMPESTCONF --out etc/tempest.conf \
    --deployer-input /var/lib/tempest/tempest-deployer-input.conf \
  --network-id $public_net_id \
      --image http://download.cirros-cloud.net/0.3.6/cirros-0.3.6-x86_64-disk.img \
  --debug \
      --remove network-feature-enabled.api_extensions=dvr \
      --create \
    DEFAULT.log_dir /var/log/tempest \
  DEFAULT.log_file tempest.log \
        auth.use_dynamic_credentials true \
  auth.tempest_roles Member \
  network-feature-enabled.port_security true \
      network.tenant_network_cidr 192.168.0.0/24 \
  compute.build_timeout 500 \
  network.build_timeout 500 \
  volume.build_timeout 500 \
    service_available.aodh_plugin False \
      orchestration.stack_owner_role Member


### --stop_docs
## Run tempest
## -----------

## ::

export OSTESTR='ostestr'
export TEMPESTCLI='/usr/bin/tempest'
export TEMPESTDATA=/var/lib/tempest

## List tempest plugins

## ::

$TEMPESTCLI list-plugins

## Save the resources before running tempest tests
## It will create saved_state.json in tempest workspace.
## ::

$TEMPESTCLI cleanup --init-saved-state

 $TEMPESTCLI run  --regex '(tempest.api.compute.admin)'    --blacklist_file=$TEMPESTDATA/skip_file  --concurrency 5 
## Check which all tenants would be modified in the tempest run
## It will create dry_run.json in tempest workspace.
## ::

$TEMPESTCLI cleanup --dry-run

EOF
chmod +x /home/stack/tempest_container.sh
# Copy all the required files in a temprory directory
export TEMPEST_HOST_DATA='/var/lib/tempestdata'

if [ ! -d $TEMPEST_HOST_DATA ]
then
    sudo mkdir -p $TEMPEST_HOST_DATA
fi

sudo cp \
        /home/stack/overcloudrc \
            /home/stack/skip_file \
                /home/stack/tempest-deployer-input.conf \
        /home/stack/tempest_container.sh \
    $TEMPEST_HOST_DATA


export CONTAINER_BINARY='docker'

sudo $CONTAINER_BINARY pull 192.168.24.1:8787/tripleorocky/centos-binary-tempest:current-tripleo-rdo

# Run tempest container using docker mouting required files
sudo $CONTAINER_BINARY run --net=host -i -v $TEMPEST_HOST_DATA:/var/lib/tempest \
    -e PYTHONWARNINGS="${PYTHONWARNINGS:-}" \
    -e CURL_CA_BUNDLE="" \
    --user=root \
    -v /var/log/containers/tempest:/var/log/tempest \
        192.168.24.1:8787/tripleorocky/centos-binary-tempest:current-tripleo-rdo \
    /usr/bin/bash -c 'set -e; /var/lib/tempest/tempest_container.sh'

### --stop_docs
### --stop_docs
