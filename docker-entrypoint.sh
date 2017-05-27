#!/bin/dumb-init /bin/sh
set -e

# Note above that we run dumb-init as PID 1 in order to reap zombie processes
# as well as forward signals to all processes in its session. Normally, sh
# wouldn't do either of these functions so we'd leak zombies as well as do
# unclean termination of all our sub-processes.

# If the logs dir is bind mounted then chown it
if [ "$(stat -c %u /stdfile/logs)" != "$(id -u stdfile)" ]; then
    chown -R stdfile:stdfile /stdfile/logs
fi

# If the file dir is bind mounted then chown it
if [ "$(stat -c %u /stdfile/db)" != "$(id -u stdfile)" ]; then
    chown -R stdfile:stdfile /stdfile/db
fi
set -- gosu stdfile "$@"

"$@"
tail -f /stdfile/logs/log

# stop gracefully
standardfile -s stop
