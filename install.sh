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

if [ -z "$SERVICE_ENTRY" ]; then
	SERVICE_ENTRY="app.js"
fi

if [ -z "$SERVICE_BIN" ]; then
	SERVICE_BIN="node $SERVICE_ENTRY"
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

# Install init.d script
mv $SERVICE_NAME /etc/init.d/$SERVICE_NAME
chmod 755 /etc/init.d/$SERVICE_NAME
if ! [ -d "/lib/systemd/system" ]; then
	update-rc.d $SERVICE_NAME defaults
fi

# Generate systemd script
if [ -d "/lib/systemd/system" ]; then
	SYSTEMD_NAME="$SERVICE_NAME.service"

	echo "[Unit]" > $SYSTEMD_NAME
	echo "Description=$SERVICE_DESC" >> $SYSTEMD_NAME
	echo "After=network.target" >> $SYSTEMD_NAME
	echo "" >> $SYSTEMD_NAME
	echo "[Service]" >> $SYSTEMD_NAME
	echo "Type=simple" >> $SYSTEMD_NAME
	echo "User=$SERVICE_USER" >> $SYSTEMD_NAME
	echo "PIDFile=$SERVICE_RUNDIR/$SERVICE_NAME.pid" >> $SYSTEMD_NAME
	echo "ExecStart=/usr/bin/node $SERVICE_DIR/app.js 1>> $SERVICE_LOGDIR/access.log 2>> $SERVICE_LOGDIR/error.log" >> $SYSTEMD_NAME
	echo "" >> $SYSTEMD_NAME
	echo "[Install]" >> $SYSTEMD_NAME
	echo "WantedBy=multi-user.target" >> $SYSTEMD_NAME
	echo "" >> $SYSTEMD_NAME

	# Install systemd script
	mv $SYSTEMD_NAME /lib/systemd/system/
fi
