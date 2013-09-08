#!/bin/sh

APPORTABLE="/Users/$USER/.apportable/SDK/bin/apportable"
LAUNCH="${APPORTABLE} load --xcode-project ${PROJECT_NAME}.xcodeproj --xcode-target ${PROJECT_NAME}-iOS --xcode-config ${CONFIGURATION}"
APPORTABLEVERSION="${APPORTABLE} --version"


function launchApportable {
	echo "Working dir: " ${PWD}
	$APPORTABLEVERSION
	echo "Apportable command line: " ${LAUNCH}
	echo "Apportable output:"
	$LAUNCH
}

function apportableNotInstalled {
	echo "========================================================="
	echo "========================================================="
	echo "CAN'T BUILD FOR ANDROID: Apportable is not installed!"
	echo "Get your free Starter edition here: http://apportable.com"
	echo "========================================================="
	echo "========================================================="
	exit 111
}


if [ -x $APPORTABLE ]
then
	launchApportable
else
	apportableNotInstalled
fi
