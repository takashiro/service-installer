#!/bin/bash

# Define root directory of app
SERVICE_DIR=$1
if [ -z "$SERVICE_DIR" ]; then
	SERVICE_DIR=$(pwd)
fi
echo "Unstalling service at $SERVICE_DIR..."

# Read configuration
source $SERVICE_DIR/service-config.sh

if [ -z "$SERVICE_NAME" ]; then
	echo "Configuration error. Please define \$SERVICE_NAME"
	exit 1
fi

service $SERVICE_NAME stop

# Remove run directory
if [ -z "$SERVICE_RUNDIR" ]; then
	SERVICE_RUNDIR="/var/run/$SERVICE_NAME"
fi
if [ -f "$SERVICE_RUNDIR" ]; then
	rm -rf "$SERVICE_RUNDIR"
fi

# Remove systemd script
if [ -f /lib/systemd/system/$SERVICE_NAME.service ]; then
	rm /lib/systemd/system/$SERVICE_NAME.service
fi

# Remove init.d script
rm -f /etc/init.d/$SERVICE_NAME
update-rc.d $SERVICE_NAME remove
