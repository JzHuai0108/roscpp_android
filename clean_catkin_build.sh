#!/bin/bash
# To clean the catkin build. Clean may be needed after catkin package changes.

# Abort script on any failures
set -e

if [ $# != 1 ] || [ $1 == '-h' ] || [ $1 == '--help' ]; then
    echo "Usage: $0 ros_android_output_path"
    echo "  example: $0 /docker/roscpp_android_ndk/ros_android/output"
    exit 1
fi
output_path=$1

cd $output_path/catkin_ws
sudo chown -R $USER ./build
sudo chown -R $USER ./devel
sudo chown -R $USER ./logs
rm -r ./build
rm -r ./devel
rm -r ./logs

sudo chown -R $USER $output_path/target
rm -r $output_path/target
