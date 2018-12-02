#!/bin/bash

# Define root directory of app
SERVICE_DIR=$1
if [ -z "$SERVICE_DIR" ]; then
	SERVICE_DIR=$(pwd)
fi
echo "Installing service at $SERVICE_DIR..."

# Read configuration
source $SERVICE_DIR/service-config.sh

if [ -z "$SERVICE_NAME" ]; then
	echo "Please define \$SERVICE_NAME"
	exit 1
fi

if [ -z "$SERVICE_USER" ]; then
	echo "Please define \$SERVICE_USER"
	exit 1
fi

if [ -z "$SERVICE_BIN" ]; then
	SERVICE_BIN="node app.js"
fi

# Generate log directory
if [ -z "$SERVICE_LOGDIR" ]; then
	SERVICE_LOGDIR="/var/log/$SERVICE_NAME"
fi
if ! [ -f "$SERVICE_LOGDIR" ]; then
	mkdir "$SERVICE_LOGDIR"
	chown $SERVICE_USER:$SERVICE_USER "$SERVICE_LOGDIR"
fi

# Generate run directory
if [ -z "$SERVICE_RUNDIR" ]; then
	SERVICE_RUNDIR="/var/run/$SERVICE_NAME"
fi
if ! [ -f "$SERVICE_RUNDIR" ]; then
	mkdir "$SERVICE_RUNDIR"
	chown $SERVICE_USER "$SERVICE_RUNDIR"
fi

# Generate service script
echo "#!/bin/sh" >> $SERVICE_NAME
echo "" >> $SERVICE_NAME
echo "### BEGIN INIT INFO" >> $SERVICE_NAME
echo "# Provides:          $SERVICE_NAME" >> $SERVICE_NAME
echo "# Required-Start:    \$remote_fs \$syslog" >> $SERVICE_NAME
echo "# Required-Stop:     \$remote_fs \$syslog" >> $SERVICE_NAME
echo "# Default-Start:     2 3 4 5" >> $SERVICE_NAME
echo "# Default-Stop:      0 1 6" >> $SERVICE_NAME
echo "# Short-Description: $SERVICE_NAME" >> $SERVICE_NAME
echo "# Description:       $SERVICE_DESC" >> $SERVICE_NAME
echo "### END INIT INFO" >> $SERVICE_NAME
echo "" >> $SERVICE_NAME
echo "SERVICE_DIR=$SERVICE_DIR" >> $SERVICE_NAME
echo "SERVICE_LOGDIR=$SERVICE_LOGDIR" >> $SERVICE_NAME
echo "SERVICE_USER=$SERVICE_USER" >> $SERVICE_NAME
echo "SERVICE_NAME=$SERVICE_NAME" >> $SERVICE_NAME
echo "SERVICE_BIN=\"$SERVICE_BIN\"" >> $SERVICE_NAME
echo "SERVICE_PIDFILE=$SERVICE_RUNDIR/$SERVICE_NAME.pid" >> $SERVICE_NAME
echo "" >> $SERVICE_NAME
cat $(dirname $0)/initd-body.sh >> $SERVICE_NAME

# Install service script
mv $SERVICE_NAME /etc/init.d/$SERVICE_NAME
chmod 755 /etc/init.d/$SERVICE_NAME
update-rc.d $SERVICE_NAME defaults
