#!/bin/bash
# Abort script on any failures
set -e

my_loc="$(cd "$(dirname $0)" && pwd)"

echo -e '\e[34mComment out docker/build.sh if the android_ndk image has been built successfully before.\e[39m'
# $my_loc/docker/build.sh

chmod +x $my_loc/local_download.sh
$my_loc/local_download.sh $my_loc

echo
echo -e '\e[34mGetting ROS packages\e[39m'
echo

python3 $my_loc/download_ros_tar.py $my_loc/ros.rosinstall $my_loc/output/catkin_ws/src

# if opencv3 failed to build, most likely the cause is the failure to download the xfeature module.
# Use download_opencv_deps.py to download these files, following suggestions from 
# https://codeantenna.com/a/QjEf9nUtwj
# python3 $my_loc/download_opencv_deps.py $my_loc/output/catkin_ws

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
# To download https://downloads.gradle.org/distributions/gradle-4.6-all.zip in the last compiling phrase for android packages,
# the VPN may need to be turned off.

# Troubleshooting
# 1. To fix the error fatal error: X11/extensions/XShm.h: No such file or directory
# and the error error: error: conflicting types for ‘_XData32’, refer to
# https://sites.google.com/site/buildcodeproject/blog/sdl12
# This error occurred with ndk-r21e but not with ndk-r18b.

# 2. To fix an error "ordered comparison between pointers and zero " in building opencv3
# we edited the descriptor.cpp file with
# vim ./output/catkin_ws/src/opencv3/opencv_contrib/stereo/src/descriptor.cpp
# as below for line 229 - 230.
# //          CV_Assert(image.size > 0);
# //          CV_Assert(cost.size > 0);
# This error occurred with ndk-r21e but not with ndk-r18b.

# 3. cp: cannot stat '/opt/ros_android/output/libs/boost/configs/user-config-boost-1_74_0.jam': No such file or directory
# The NDK and the boost version is incompatible. Check build-android.sh in boost android for details.

# 4. error: non-constant-expression cannot be narrowed from type 'uint32_t' (aka 'unsigned int') to '__kernel_time_t' (aka 'long') in initializer list 

# update line 254 and line 269 in output/catkin_ws/src/roscpp_core/rostime/src/time.cpp as below.
# timespec req = { (long)sec, (long)nsec };

# 5. pcl and boost error /opt/ros_android/output/libs/pcl/common/include/pcl/PCLPointCloud2.h:11:10: fatal error: 'boost/detail/endian.hpp' file not found
#include <boost/detail/endian.hpp>
# upgrade pcl to the one using an alternative header.

# 6. use diff and patch together for two files.
# https://www.techtarget.com/searchdatacenter/tip/An-introduction-to-using-diff-and-patch-together?Offer=abt_pubpro_AI-Insider
# we may also use git diff and patch for better efficiency with multiple files.