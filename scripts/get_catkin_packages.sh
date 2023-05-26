#!/bin/bash
# Gets ROS packages and creates a catkin workspace.
# See help for required positional arguments.
# 
# Required environment variables:
# - SCRIPT_DIR: where utility scripts are located.

# Abort script on any failures
set -e

source $SCRIPT_DIR/utils.sh

if [ $# != 2 ] || [ "$1" == '-h' ] || [ "$1" == '--help' ]; then
    echo "Usage: $0 rosinstall_file prefix_path"
    echo "  example: $0 /home/user/ros_android/ros.rosinstall /home/user/ros_android/output"
    exit 1
fi

cmd_exists git || die 'git was not found'
cmd_exists wstool || die 'wstool was not found'

rosinstall_file="$1"
prefix=$(cd $2 && pwd)

cd $prefix
mkdir -p catkin_ws/src && cd catkin_ws

pushd src
if [ ! -f .rosinstall ]; then
  ln -sf $rosinstall_file .rosinstall
fi
wstool update -j$PARALLEL_JOBS
popd
