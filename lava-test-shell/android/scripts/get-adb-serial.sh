#!/bin/sh

SKIP_INSTALL="true"

usage() {
    echo "Usage: $0 [-S <true|false>]" 1>&2
    exit 1
}

while getopts ":S:s:t:l:n:d:u:g:" opt; do
    case "${opt}" in
        S) SKIP_INSTALL="${OPTARG}" ;;
        *) usage ;;
    esac
done


if [ "${SKIP_INSTALL}" = "true" ] || [ "${SKIP_INSTALL}" = "True" ]; then
    echo "Package installation skipped"
    lava-test-case install-base --result skip
else
    apt-get update -q
    DEBIAN_FRONTEND=noninteractive lava-test-case install-base --shell apt-get -q -y install -o Dpkg::Options::="--force-confold" adb fastboot android-tools-adb android-tools-fastboot
fi

which adb
# start daemon if not yet running.
adb start-server || true
adb wait-for-device
echo
# start adb and stop the daemon start message from appearing in $result
lava-test-case adb-serial --shell adb get-serialno
result=$(adb get-serialno 2>&1 | tail -n1)
if [ "$result" = "unknown" ]; then
    echo "ERROR: adb get-serialno returned" $result
    exit 1
else
    echo "adb get-serialno returned" $result
    echo $result > adb-connection.txt
    exit 0
fi
