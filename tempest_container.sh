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

