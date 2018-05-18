#!/bin/bash
# set -x
OPENFILES_CRIT=1
OPENFILES_WARN=1
OPENFILES_FILTER=""
LSOF_EXTRA=""

while [ -n "$1" ] ; do
	case "$1" in
		-c)
			OPENFILES_CRIT=$2
			shift
			;;
		-w)
			OPENFILES_WARN=$2
			shift
			;;
		-f)
			OPENFILES_FILTER="$2"
			shift
			;;
		-u)
			LSOF_EXTRA="${LSOF_EXTRA} +u$2"
			shift
			;;
		*)
			echo "UNKNOWN: Unknown parameter $1"
			exit 3
			shift
			;;
	esac
	shift
done

OPENFILES_COUNT="$(lsof -n -a +L1 -F n $LSOF_EXTRA | grep "${OPENFILES_FILTER}" | grep -c "^n/")"

if [ $OPENFILES_COUNT -ge $OPENFILES_CRIT ] ; then
	echo "CRITICAL: $OPENFILES_COUNT open files"
	exit 2
elif [ $OPENFILES_COUNT -ge $OPENFILES_WARN ] ; then
        echo "WARNING: $OPENFILES_COUNT open files"
        exit 2
fi
echo "OK: $OPENFILES_COUNT open files"
exit 0
