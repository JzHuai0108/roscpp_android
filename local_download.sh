#!/bin/bash

my_loc=/media/jhuai/docker/roscpp_android_ndk/roscpp_android
prefix=/media/jhuai/docker/roscpp_android_ndk/roscpp_android/output

# Abort script on any failures
set -e

# Define the number of simultaneous jobs to trigger for the different
# tasks that allow it. Use the number of available processors in the
# system.
export PARALLEL_JOBS=$(nproc)

source $my_loc/config.sh
source $my_loc/utils.sh
debugging=0
skip=0
portable=0
help=0

# verbose is a bool flag indicating if we want more verbose output in
# the build process. Useful for debugging build system or compiler errors.
verbose=0


for var in "$@"
do
    if [[ ${var} == "--help" ]] ||  [[ ${var} == "-h" ]] ; then
        help=1
    fi
    if [[ ${var} == "--skip" ]] ; then
        skip=1
    fi

    if [[ ${var} == "--debug-symbols" ]] ; then
        debugging=1
    fi

    if [[ ${var} == "--portable" ]] ; then
        portable=1
    fi
done

if [[ $help -eq 1 ]] ; then
    echo "Usage: $0 prefix_path [-h | --help] [--skip] [--debug-symbols]"
    echo "  example: $0 /home/user/my_workspace"
    exit 1
fi

if [[ $skip -eq 1 ]]; then
   echo "-- Skiping projects update"
else
   echo "-- Will update projects"
fi

if [[ $debugging -eq 1 ]]; then
   echo "-- Building workspace WITH debugging symbols"
else
   echo "-- Building workspace without debugging symbols"
fi

if [ ! -d $1 ]; then
    mkdir -p $1
fi

run_cmd() {
    cmd=$1.sh
    shift
    $my_loc/$cmd $@ || die "$cmd $@ died with error code $?"
}

echo
echo -e '\e[34mGetting library dependencies.\e[39m'
echo

mkdir -p $prefix/libs

# Start with catkin since we use it to build almost everything else
[ -d $prefix/target ] || mkdir -p $prefix/target
export CMAKE_PREFIX_PATH=$prefix/target

# Get the android ndk build helper script
# If file doesn't exist, then download and patch it
echo "prefix:$prefix, my_loc:$my_loc."
if ! [ -e $prefix/android.toolchain.cmake ]; then
    cd $prefix
    download 'https://raw.githubusercontent.com/taka-no-me/android-cmake/556cc14296c226f753a3778d99d8b60778b7df4f/android.toolchain.cmake'
    patch -p0 -N -d $prefix < /opt/roscpp_android/patches/android.toolchain.cmake.patch
    cat $my_loc/files/android.toolchain.cmake.addendum >> $prefix/android.toolchain.cmake
fi

export RBA_TOOLCHAIN=$prefix/android.toolchain.cmake

# Now get boost with a specialized build
[ -d $prefix/libs/boost ] || run_cmd get_library boost $prefix/libs
[ -d $prefix/libs/bzip2 ] || run_cmd get_library bzip2 $prefix/libs
[ -d $prefix/libs/uuid ] || run_cmd get_library uuid $prefix/libs
[ -d $prefix/libs/poco-1.6.1 ] || run_cmd get_library poco $prefix/libs
[ -d $prefix/libs/tinyxml ] || run_cmd get_library tinyxml $prefix/libs
[ -d $prefix/libs/catkin ] || run_cmd get_library catkin $prefix/libs
[ -d $prefix/libs/console_bridge ] || run_cmd get_library console_bridge $prefix/libs
[ -d $prefix/libs/lz4-r124 ] || run_cmd get_library lz4 $prefix/libs
[ -d $prefix/libs/curl-7.39.0 ] || run_cmd get_library curl $prefix/libs
[ -d $prefix/libs/urdfdom/ ] || run_cmd get_library urdfdom $prefix/libs
[ -d $prefix/libs/urdfdom_headers ] || run_cmd get_library urdfdom_headers $prefix/libs
[ -d $prefix/libs/libiconv-1.14 ] || run_cmd get_library libiconv $prefix/libs
[ -d $prefix/libs/libxml2-2.9.1 ] || run_cmd get_library libxml2 $prefix/libs
[ -d $prefix/libs/collada-dom-2.4.0 ] || run_cmd get_library collada_dom $prefix/libs
[ -d $prefix/libs/eigen ] || run_cmd get_library eigen $prefix/libs
[ -d $prefix/libs/assimp-3.1.1 ] || run_cmd get_library assimp $prefix/libs
[ -d $prefix/libs/qhull-2012.1 ] || run_cmd get_library qhull $prefix/libs
[ -d $prefix/libs/octomap-1.6.8 ] || run_cmd get_library octomap $prefix/libs
[ -d $prefix/libs/yaml-cpp ] || run_cmd get_library yaml-cpp $prefix/libs
[ -d $prefix/libs/opencv-2.4.9 ] || run_cmd get_library opencv $prefix/libs
[ -d $prefix/libs/flann ] || run_cmd get_library flann $prefix/libs
[ -d $prefix/libs/pcl ] || run_cmd get_library pcl $prefix/libs
[ -d $prefix/libs/bfl-0.7.0 ] || run_cmd get_library bfl $prefix/libs
[ -d $prefix/libs/orocos_kdl-1.3.0 ] || run_cmd get_library orocos_kdl $prefix/libs
[ -d $prefix/libs/apache-log4cxx-0.10.0 ] || run_cmd get_library log4cxx $prefix/libs
[ -d $prefix/libs/libccd-2.0 ] || run_cmd get_library libccd $prefix/libs
[ -d $prefix/libs/fcl-0.3.2 ] || run_cmd get_library fcl $prefix/libs
[ -d $prefix/libs/pcrecpp ] || run_cmd get_library pcrecpp $prefix/libs
# get rospkg dependency for pluginlib support at build time
[ -d $my_loc/files/rospkg ] || run_cmd get_library rospkg $my_loc/files

[ -f $prefix/target/bin/catkin_make ] || run_cmd build_library catkin $prefix/libs/catkin
. $prefix/target/setup.bash

echo
echo -e '\e[34mGetting ROS packages\e[39m'
echo
