#!/bin/bash
# Copies boost compiled libraries to the target installation directory.
# See help for required positional arguments.
#
# Required environment variables:
# - ANDROID_ABI: Selected Android Binary Interface.
# - SCRIPT_DIR: where utility scripts are located.
# - TARGET_DIR: where to copy boost files.

# Abort script on any failures
set -e

source $SCRIPT_DIR/utils.sh

if [ $# != 1 ] || [ "$1" == '-h' ] || [ "$1" == '--help' ]; then
    echo "Usage: $0 boost_prefix_path"
    echo "  example: $0 /home/user/ros_android/output/libs/boost"
    exit 1
fi

prefix=$(cd $1 && pwd)

echo
echo -e '\e[34mCopying boost.\e[39m'
echo

[ "$TARGET_DIR" = "" ] && die 'could not find target basedir. Please set $TARGET_DIR environment variable.'
mkdir -p $TARGET_DIR/lib
cd $prefix/build/out/$ANDROID_ABI/lib/
for i in *.a # Rename and move libraries (remove the gcc type, so on)
do
    #mv "$i" "`echo $i | sed 's/000//'`"
    #cp lib/lib*.a ./
    cp "$i" $TARGET_DIR/lib/"`echo $i | sed 's/ *\-.*//'`.a"
done

cd ../include
mkdir -p $TARGET_DIR/include
cp -R boost-1_74/boost $TARGET_DIR/include/
