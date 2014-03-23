#!/bin/sh

# NOTE: to run this script you need to have appledoc in your path: https://github.com/tomaz/appledoc
# Either clone & make appledoc yourself or use homebrew (other installers like fink might also work).

# This script assumes that the working directory is set to where the script is located.

function makeDocs {
	referenceShortName=$1
	docsetFilename="com.$referenceShortName.docset"
	sourcePath="$2/$referenceShortName"
	
	if [ -e ./$referenceShortName ]
	then
		rm -r ./$referenceShortName
	fi
	if [ -e ./$docsetFilename ] 
	then
		rm -r ./$docsetFilename
	fi
	
	COMMON="--keep-intermediate-files -p $1 --verbose 2 --no-repeat-first-par --create-html --no-warn-invalid-crossref"
	INDEX="--index-desc $sourcePath/Documentation/index.appledoc"
	INCLUDE="--include $sourcePath/Documentation --ignore *.m --ignore *.mm --ignore *.c --ignore *.cpp"
	DOCSET="--create-docset --install-docset --docset-install-path ./ --keep-intermediate-files"
	DOCSETREF="--docset-bundle-name $referenceShortName --docset-desc $referenceShortName-Reference --docset-bundle-id com.$referenceShortName --docset-bundle-filename $docsetFilename"
	OUTPUT="--output ./$referenceShortName $sourcePath"
	KEEPUNDOC="--keep-undocumented-members --keep-undocumented-objects"
	KEEPUNDOC=""
	
	# make html & xcode docs
	echo Generating $1 documentation ...
	#echo appledoc $COMMON $INDEX $INCLUDE $DOCSET $DOCSETREF $KEEPUNDOC $OUTPUT
	appledoc $COMMON $INDEX $INCLUDE $DOCSET $DOCSETREF $KEEPUNDOC $OUTPUT
	
	# remove the source files for the docset
	if [ -e ./$referenceShortName/docset ]
	then
		rm -r ./$referenceShortName/docset
	fi
	if [ -e ./$referenceShortName/docset-installed.txt ]
	then
		rm ./$referenceShortName/docset-installed.txt
	fi
	
	# copy the docset
	docsetPath=~/Library/Developer/Shared/Documentation/DocSets/$docsetFilename
	if [ -e $docsetPath ] 
	then
		rm -r $docsetPath
	fi
	if [ -e ./$docsetFilename ] 
	then
		echo Installing to Xcode Help: $docsetFilename
		cp -r ./$docsetFilename ~/Library/Developer/Shared/Documentation/DocSets
	fi

	# create the index.html forward
	echo "<!DOCTYPE HTML><META http-equiv=\"refresh\" content=\"0; url=./html/index.html\">" > ./$referenceShortName/index.html
}

cd ..
cd docs

if [ -z "$1" ]
then
	makeDocs "OpenGW" "../.."
	makeDocs "KoboldKitFree" "../../KoboldKit/"
	makeDocs "KoboldKitExternal" "../../KoboldKit/"
	#makeDocs "KoboldKitCommunity" "../../KoboldKit/"
	#makeDocs "KoboldKitPro" "../../KoboldKit/"
else
	makeDocs $1 $2
fi

echo Done!
