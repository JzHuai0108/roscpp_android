#!/bin/bash
# Builds a target library using cmake.
# See help for required positional arguments.
# 
# Required environment variables:
# - SCRIPT_DIR: where utility scripts are located.

# Abort script on any failures
set -e

source $SCRIPT_DIR/utils.sh

if [ $# -eq 0 ] || [ "$1" == '-h' ] || [ $1 == '--help' ]; then
    echo "Usage: $0 library library_source_dir"
    echo "  example: $0 tinyxml /home/user/ros_android/output/libs/tinyxml"
    exit 1
fi

echo
echo -e '\e[34mBuilding '"$1".'\e[39m'
echo

cmake_build "$2"
