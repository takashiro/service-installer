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

rm -f /etc/init.d/$SERVICE_NAME
update-rc.d $SERVICE_NAME remove
