#!/bin/sh

# ensure script isn't run as root, which would mess up permissions
if [[ "$(id -u)" == "0" ]]; then
	echo "Sorry, you can't (shouldn't) run this script as root." 1>&2
	echo "Simply re-run the script, omitting the 'sudo' command." 1>&2
	echo "" 1>&2
	echo "Reason: Xcode docsets are installed to a user folder. If the installation is performed as root, it can cause all sorts of permission issues including unable to update or install other Xcode documentation." 1>&2
	exit 1
fi

# create the docset dir, if necessary
docsetDir="${HOME}/Library/Developer/Shared/Documentation/DocSets"
echo "Installing docsets to:\n " $docsetDir
if [ ! -d $docsetDir ]; then
	mkdir $docsetDir
fi

didLocateDir=0

# set the working dir
if [ -d ../Docs ]; then
	cd ../Docs
	didLocateDir=1
fi
if [ -d ./KoboldAid/Docs ]; then
	cd ./KoboldAid/Docs
	didLocateDir=1
fi

if (( didLocateDir < 1 )); then
	echo "Sorry, you must run the script from the KoboldKit root or the /KoboldAid/Scripts directory." 1>&2
	exit 1
fi

# copy the docsets
for docset in $(ls -d com.*.docset/)
do
	docset=${docset:0:${#docset} - 1}
	echo Installing: $docset
	
	rm -rf $docsetDir/$docset
	cp -r $docset $docsetDir
done

echo "Done."
