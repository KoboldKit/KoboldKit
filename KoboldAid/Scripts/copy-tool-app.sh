#!/bin/sh
# copies the .app to the KoboldKit root folder for end users

source=$CONFIGURATION_BUILD_DIR/$TARGET_NAME.app
# remove substring to generate path to KoboldTouch root folder
target=${PROJECT_DIR%%/KoboldAid/tools/$TARGET_NAME}
echo Copy $TARGET_NAME.app to $target

target="$target/$TARGET_NAME.app"

if [ -e $target ]
then
	rm -r $target
fi

cp -R "$source" "$target"
