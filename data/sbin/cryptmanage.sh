#!/bin/bash

# ###################################################################################
# ###################################################################################
# ###################################################################################
#
# cryptmanage.sh
#
# Michael Hammes, 2022
# Apache License, Version 2.0, January 2004
#
# ###################################################################################
# ###################################################################################
# ###################################################################################


# $1: UUID of drive to mount, leave empty to list all drives
# $2: PASS of drive to mount, leave empty to umount

function dolog() {
	echo $1
}
function doerr() {
	logger -st "$(basename "${0%.*}")($DEVNAME)[$$]" -- "$@"
}

function domount() {

	# Attempt to find blk device with UUID
	while IFS= read -r blkpath; do

			# Read and parse information
			BID_RAW="$(block info "$blkpath" | awk -v RS=' ' '{gsub("[:\"]",""); print $0}')"
			BID_UUID="$(awk -F= '/UUID/ {print $2}' <<< "$BID_RAW")"
			BID_TYPE="$(awk -F= '/TYPE/ {print $2}' <<< "$BID_RAW")"

			if [ "$BID_TYPE" == "crypto_LUKS" ] && [ "$BID_UUID" == "$1" ]; then

					# Unlock if required
					cryptsetup status "/dev/mapper/$1" > /dev/null
					if [ $? -ne 0 ]; then
							dolog "Unlocking volume $blkpath to /dev/mapper/$1 ..."
							echo -n "$2" | cryptsetup luksOpen "$blkpath" "$1" -d -
							if [ $? -ne 0 ]; then doerr "Failed to unlock volume."; return 3; fi
					fi
					dolog "Volume unlocked."

					# Mount if required
					mount | grep "/dev/mapper/$1" > /dev/null
					if [ $? -ne 0 ]; then
							dolog "Mounting volume..."
							block mount
							mount | grep "/dev/mapper/$1" > /dev/null
							if [ $? -ne 0 ]; then doerr "Failed to mount volume."; return 4; fi
					fi
					dolog "Volume mounted."
					
					return 0

			fi
	done <<< $(find /dev -regex "/dev/sd[a-z][0-9]")

	dolog "Failed to find device $1 ."
	return 2
}

function doumount() {

	# Umount if required
	mount | grep "/dev/mapper/$1" > /dev/null
	if [ $? -eq 0 ]; then
			dolog "Umounting volume..."
			umount "/dev/mapper/$1"
			if [ $? -ne 0 ]; then doerr "Failed to umount volume."; return 2; fi
			dolog "Volume umounted."
	else
		dolog "Volume not mounted."
	fi
		

	# Lock if required
	cryptsetup status "$1" > /dev/null
	if [ $? -eq 0 ]; then
			dolog "Locking volume $1 ..."
			cryptsetup luksClose "$1"
			if [ $? -ne 0 ]; then doerr "Failed to lock volume."; return 3; fi
			dolog "Volume locked."
	else
		dolog "Volume not unlocked."
	fi

	return 0
}

if [ "$1" == "" ]; then
	/sbin/block info
	exit $?
else
	if [[ ! $1 =~ ^([a-fA-F0-9\-]+)$ ]]; then doerr "Invalid UUID."; exit 1; fi
	if [ ! "$2" == "" ]; then
		if [[ ! $2 =~ ^([[:print:]]+)$ ]]; then doerr "Invalid PASSWORD."; exit 2; fi
		domount $1 $2
		exit $?
	else
		doumount $1
		exit $?
	fi
fi
