#!/bin/bash

# Abort script on any failures
set -e

my_loc="$(cd "$(dirname $0)" && pwd)"

if [ $# != 2 ] || [ $1 == '-h' ] || [ $1 == '--help' ]; then
    echo "Usage: $0 output_path portable"
    echo "  example: $0 /docker/roscpp_android_ndk/ros_android/output 0, will use external links"
    echo "  example: $0 /docker/roscpp_android_ndk/ros_android/output 1, will use copy all required files"
    exit 1
fi
output_path=$1
if [ ! -d $1/roscpp_android_ndk ]; then
    mkdir -p $1/roscpp_android_ndk
fi

cd $1/roscpp_android_ndk

if [[ $2 -eq 0 ]]; then
  ln -fs $output_path/target/include ./
  ln -fs $output_path/target/lib ./
  ln -fs $output_path/target/share ./
else
  cp -r $output_path/target/include ./
  cp -r $output_path/target/lib ./
  cp -r $output_path/target/share ./
fi

cp $my_loc/files/roscpp_android_ndk/*.mk ./
