# Service Functions

check_status() {
	if [ ! -f "$SERVICE_PIDFILE" ]; then
		return 1
	fi

	local PID=$(cat "$SERVICE_PIDFILE")
	if [ -z "$PID" ] || ! kill -0 "$PID" 2>/dev/null; then
		rm -f "$SERVICE_PIDFILE"
		return 1
	fi

	return 0
}

start() {
	if check_status; then
		echo "$SERVICE_NAME is already running." >&2
		return 1
	fi
	echo "Starting $SERVICE_NAME..." >&2
	cd $SERVICE_DIR

	if [ ! -f "$SERVICE_RUNDIR" ]; then
		mkdir -p $SERVICE_RUNDIR
		chown $SERVICE_USER:$SERVICE_USER $SERVICE_RUNDIR
	fi

	local CMD="$SERVICE_BIN 1>> $SERVICE_LOGDIR/access.log 2>> $SERVICE_LOGDIR/error.log & echo \$!"
	su -s "/bin/bash" -c "$CMD" $SERVICE_USER > "$SERVICE_PIDFILE" &
	echo "$SERVICE_NAME is running." >&2
}

stop() {
	if ! check_status; then
		echo "$SERVICE_NAME is not running." >&2
		return 1
	fi
	echo "Stopping $SERVICE_NAME..." >&2
	kill -15 $(cat $SERVICE_PIDFILE)
	rm -f "$SERVICE_PIDFILE"
	echo "$SERVICE_NAME is stopped." >&2
}

status() {
	if check_status; then
		echo "$SERVICE_NAME is running." >&2
	else
		echo "$SERVICE_NAME is not running." >&2
	fi
}

case "$1" in
	start)
		start
		;;
	stop)
		stop
		;;
	status)
		status
		;;
	restart)
		stop
		start
		;;
	*)
	echo "Usage: $0 {start|stop|restart|status}"
esac
