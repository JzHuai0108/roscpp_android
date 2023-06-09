#!/bin/bash
# Gets system dependencies in a target directory.
# See help for required positional arguments.

# Required environment variables:
# - SCRIPT_DIR: where utility scripts are located.

# Abort script on any failures
set -e

source $SCRIPT_DIR/utils.sh

if [ $# != 2 ] || [ "$1" == '-h' ] || [ "$1" == '--help' ]; then
    echo "Usage: $0 system_deps_rosinstall library_prefix_path"
    echo "  example: $0 /home/user/ros_android/system_deps.rosinstall /home/user/my_workspace/output/libs"
    echo $@
    exit 1
fi

echo
echo -e '\e[34mGetting system libraries.\e[39m'
echo

cmd_exists wstool || die 'wstool was not found'

rosinstall_file="$1"
lib_prefix=$(cd "$2" && pwd)

pushd $lib_prefix
if [ ! -f .rosinstall ]; then
  ln -sf $rosinstall_file .rosinstall
fi

echo "lib_prefix:$lib_prefix."
# wstool update -j$PARALLEL_JOBS

run_cmd() {
    cmd="$1".sh
    shift
    if [ -x $SCRIPT_DIR/$cmd ]; then
        cmd=$SCRIPT_DIR/$cmd
    elif [ -x $BASE_DIR/$cmd ]; then
        cmd=$BASE_DIR/$cmd
    fi
    $cmd "$@" || die "$cmd $@ died with error code $?"
}

[ -d $lib_prefix/assimp ] || run_cmd get_library assimp $lib_prefix
[ -d $lib_prefix/boost ] || run_cmd get_library boost $lib_prefix
[ -d $lib_prefix/bullet ] || run_cmd get_library bullet $lib_prefix
[ -d $lib_prefix/bzip2 ] || run_cmd get_library bzip2 $lib_prefix
[ -d $lib_prefix/collada_dom ] || run_cmd get_library collada_dom $lib_prefix
[ -d $lib_prefix/console_bridge ] || run_cmd get_library console_bridge $lib_prefix
[ -d $lib_prefix/curl ] || run_cmd get_library curl $lib_prefix
[ -d $lib_prefix/eigen ] || run_cmd get_library eigen $lib_prefix
[ -d $lib_prefix/flann ] || run_cmd get_library flann $lib_prefix
[ -d $lib_prefix/libiconv ] || run_cmd get_library libiconv $lib_prefix
[ -d $lib_prefix/libxml2 ] || run_cmd get_library libxml2 $lib_prefix
[ -d $lib_prefix/lz4 ] || run_cmd get_library lz4 $lib_prefix
[ -d $lib_prefix/ogg ] || run_cmd get_library ogg $lib_prefix
[ -d $lib_prefix/pcl ] || run_cmd get_library pcl $lib_prefix
[ -d $lib_prefix/poco ] || run_cmd get_library poco $lib_prefix
[ -d $lib_prefix/qhull ] || run_cmd get_library qhull $lib_prefix
[ -d $lib_prefix/sdl ] || run_cmd get_library sdl $lib_prefix
[ -d $lib_prefix/sdl-image ] || run_cmd get_library sdl-image $lib_prefix
[ -d $lib_prefix/theora ] || run_cmd get_library theora $lib_prefix
[ -d $lib_prefix/tinyxml ] || run_cmd get_library tinyxml $lib_prefix
[ -d $lib_prefix/tinyxml2 ] || run_cmd get_library tinyxml2 $lib_prefix
[ -d $lib_prefix/urdfdom ] || run_cmd get_library urdfdom $lib_prefix
[ -d $lib_prefix/urdfdom_headers ] || run_cmd get_library urdfdom_headers $lib_prefix
[ -d $lib_prefix/uuid ] || run_cmd get_library uuid $lib_prefix
[ -d $lib_prefix/vorbis ] || run_cmd get_library vorbis $lib_prefix
[ -d $lib_prefix/yaml-cpp ] || run_cmd get_library yaml-cpp $lib_prefix

# [ -d $lib_prefix/catkin ] || run_cmd get_library catkin $lib_prefix
# [ -d $lib_prefix/console_bridge ] || run_cmd get_library console_bridge $lib_prefix
# [ -d $lib_prefix/octomap-1.6.8 ] || run_cmd get_library octomap $lib_prefix
# [ -d $lib_prefix/opencv-2.4.9 ] || run_cmd get_library opencv $lib_prefix
# [ -d $lib_prefix/bfl-0.7.0 ] || run_cmd get_library bfl $lib_prefix
# [ -d $lib_prefix/orocos_kdl-1.3.0 ] || run_cmd get_library orocos_kdl $lib_prefix
# [ -d $lib_prefix/apache-log4cxx-0.10.0 ] || run_cmd get_library log4cxx $lib_prefix
# [ -d $lib_prefix/libccd-2.0 ] || run_cmd get_library libccd $lib_prefix
# [ -d $lib_prefix/fcl-0.3.2 ] || run_cmd get_library fcl $lib_prefix
# [ -d $lib_prefix/pcrecpp ] || run_cmd get_library pcrecpp $lib_prefix
# # get rospkg dependency for pluginlib support at build time
# [ -d $my_loc/files/rospkg ] || run_cmd get_library rospkg $my_loc/files

popd
