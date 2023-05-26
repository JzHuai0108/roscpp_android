#!/bin/bash
# Abort script on any failures
set -e

my_loc="$(cd "$(dirname $0)" && pwd)"

# $my_loc/docker/build.sh

chmod +x $my_loc/local_download.sh
$my_loc/local_download.sh $my_loc

echo
echo -e '\e[34mGetting ROS packages\e[39m'
echo

python3 $my_loc/download_ros_tar.py $my_loc/ros.rosinstall $my_loc/output/catkin_ws/src

prefix=$my_loc/output
export SCRIPT_DIR=$my_loc/scripts
BASE_DIR=$my_loc
source $SCRIPT_DIR/utils.sh
run_cmd() {
    cmd="$1".sh
    shift
    echo "out script_dir $SCRIPT_DIR"
    if [ -x $SCRIPT_DIR/$cmd ]; then
        cmd=$SCRIPT_DIR/$cmd
    elif [ -x $BASE_DIR/$cmd ]; then
        cmd=$BASE_DIR/$cmd
    fi
    $cmd "$@" || die "$cmd $@ died with error code $?"
}

run_cmd apply_patches $my_loc/patches $prefix

$my_loc/docker/run.sh -- /opt/ros_android/install.sh /opt/ros_android/output --samples --skip
