#!/bin/bash
# See help message for usage instructions.

print_help() {
    echo "Usage: $0 prefix_path [-h | --help] [--skip] [-s | --samples] [--debug-symbols] [-p | --plugin-search-paths path_list] [-v | --verbose]"
    echo "prefix_path can be specified also after -o | --output"
    echo "  example: $0 /home/user/my_workspace --plugin-search-paths /home/user/other_workspace_to_search_plugins /home/user/another_workspace_to_search_plugins --samples"
    echo " prefix_path: Output directory. Structure ->"
    echo "              --- catkin_ws: Catkin workspace where ros packages are downloaded and built."
    echo "              --- libs: Directory where other libraries are downloaded."
    echo "              --- target: Directory where things (libraries, binaries, includes, extras, etc) are installed."
    echo " -p | --plugin-search-paths path1 [path2 ...]: Additional directories in which pluginlib plugins are searched."
    echo " -s | --samples: Build the provided example workspace. Also, search plugins there."
    echo " -v | --verbose: Indicates more verbose output. Useful for debugging."
    echo " --skip: Avoid downloading ros packages again."
    echo " -h | --help: Print this."
    echo " --debug-symbols: Build all with debug symbols."
}

# Abort script on any failures
set -e

my_loc="$(cd "$(dirname $0)" && pwd)"
debugging=0
skip=0
help=0
samples=0
declare -a plugin_search_paths

# verbose is a bool flag indicating if we want more verbose output in
# the build process. Useful for debugging build system or compiler errors.
verbose=0


if [[ $# -lt 1 ]] ; then
    help=1
fi

while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        -h|--help)
            help=1
        ;;
        --skip)
            skip=1
        ;;
        --debug-symbols)
            debugging=1
        ;;
        -p|--plugin-search-paths)
            while [[ -d "$2" ]]; do
                plugin_search_paths+=("$(cd "$2" && pwd)")
                shift
            done
        ;;
        -s|--samples)
            samples=1
        ;;
        -v|--verbose)
            verbose=1
        ;;
        -o|--output)
            if [[ -z "$prefix" ]]; then
                if [ ! -d "$2" ]; then
                    mkdir -p "$2"
                fi
                prefix=$(cd "$2" && pwd)
            else
                echo "You have specified more than one prefix"
                help=1
                break
            fi
            shift
        ;;
        -*)
            echo "Unrecognized option: $1"
            help=1
            break
        ;;
        *)
            if [[ -z "$prefix" ]]; then
                if [ ! -d "$1" ]; then
                    set +e
                    mkdir -p "$1"
                    set -e
                fi
                prefix=$(cd "$1" && pwd)
            else
                echo "You have specified more than one prefix"
                help=1
                break
            fi
        ;;
    esac
    shift
done

if [[ -z "$prefix" ]]; then
    help=1
fi

if [[ $help -eq 1 ]] ; then
    print_help
    exit 1
fi

# Export common paths
source $my_loc/scripts/config.sh
export OUTPUT_DIR="$prefix"
export TARGET_DIR=$OUTPUT_DIR/target
export LIBS_DIR=$OUTPUT_DIR/libs
source $SCRIPT_DIR/utils.sh

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

if [[ $samples -eq 1 ]]; then
   echo "-- Will build samples"
   plugin_search_paths+=("${my_loc}/example_workspace")
fi

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

if [ -z $ANDROID_NDK_HOME ] ; then
    die "ANDROID_NDK_HOME ENVIRONMENT NOT FOUND!"
fi

[ -d $standalone_toolchain_path ] || run_cmd setup_standalone_toolchain

echo
echo -e '\e[34mGetting library dependencies.\e[39m'
echo

mkdir -p $LIBS_DIR

[ -d $TARGET_DIR ] || mkdir -p $TARGET_DIR

export RBA_TOOLCHAIN=$my_loc/cmake/android.toolchain.cmake

# Get all library dependencies.
run_cmd get_system_dependencies $my_loc/system_deps.rosinstall $LIBS_DIR

# Library-specific patches / actions.
# Boost
pushd $LIBS_DIR/boost
[ -d build/out ] || bash -x ./build-android.sh $ANDROID_NDK_HOME --boost=1.74.0 --arch=$ANDROID_ABI
popd

echo
echo -e '\e[34mGetting ROS packages\e[39m'
echo

if [[ $skip -ne 1 ]] ; then
    run_cmd get_catkin_packages $my_loc/ros.rosinstall $prefix

    run_cmd apply_patches $my_loc/patches $prefix
fi

# Before build
# Search packages that depend on pluginlib and generate plugin loader.
echo
echo -e '\e[34mBuilding pluginlib support...\e[39m'
echo

pluginlib_helper_file=pluginlib_helper.cpp
$my_loc/scripts/pluginlib_helper/pluginlib_helper.py -scanroot $prefix/catkin_ws/src ${plugin_search_paths[*]} -cppout $prefix/catkin_ws/src/pluginlib/src/$pluginlib_helper_file
line="add_library(pluginlib STATIC src/pluginlib_helper.cpp)"
# temporally turn off error detection
set +e
grep "$line" $prefix/catkin_ws/src/pluginlib/CMakeLists.txt
# if line is not already added, then add it to the pluginlib cmake
if [ $? -ne 0 ]; then
    # backup the file
    cp $prefix/catkin_ws/src/pluginlib/CMakeLists.txt $prefix/catkin_ws/src/pluginlib/CMakeLists.txt.bak
    sed -i '/INCLUDE_DIRS include/a LIBRARIES ${PROJECT_NAME}' $prefix/catkin_ws/src/pluginlib/CMakeLists.txt
    echo -e "\n"$line >> $prefix/catkin_ws/src/pluginlib/CMakeLists.txt
    echo 'install(TARGETS pluginlib RUNTIME DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION} ARCHIVE DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION} LIBRARY DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION})' >> $prefix/catkin_ws/src/pluginlib/CMakeLists.txt
fi
# turn error detection back on
set -e

echo
echo -e '\e[34mBuilding library dependencies.\e[39m'
echo

# Copy c++_shared library to target space
if [ "$ANDROID_STL" = "c++_shared" ]; then
    mkdir -p $TARGET_DIR/lib
    cp -uv $ANDROID_NDK_HOME/sources/cxx-stl/llvm-libc++/libs/$ANDROID_ABI/libc++_shared.so $TARGET_DIR/lib
fi

# if the library doesn't exist, then build it
[ -f $TARGET_DIR/lib/libbz2.a ] || run_cmd build_library_with_cmake bzip2 $LIBS_DIR/bzip2
[ -f $TARGET_DIR/lib/libuuid.a ] || run_cmd build_library_with_cmake uuid $LIBS_DIR/uuid
[ -f $TARGET_DIR/lib/libboost_system.a ] || run_cmd copy_boost $LIBS_DIR/boost
[ -f $TARGET_DIR/lib/libPocoFoundation.a ] || run_cmd build_library_with_toolchain poco $LIBS_DIR/poco
[ -f $TARGET_DIR/lib/libtinyxml.a ] || run_cmd build_library_with_cmake tinyxml $LIBS_DIR/tinyxml
[ -f $TARGET_DIR/lib/libtinyxml2.a ] || run_cmd build_library_with_cmake tinyxml2 $LIBS_DIR/tinyxml2
[ -f $TARGET_DIR/lib/libconsole_bridge.a ] || run_cmd build_library_with_cmake console_bridge $LIBS_DIR/console_bridge
[ -f $TARGET_DIR/lib/liblz4.a ] || run_cmd build_library_with_cmake lz4 $LIBS_DIR/lz4/cmake_unofficial
[ -f $TARGET_DIR/lib/libcurl.a ] || run_cmd build_library_with_toolchain curl $LIBS_DIR/curl
[ -f $TARGET_DIR/include/urdf_model/model.h ] || run_cmd build_library_with_cmake urdfdom_headers $LIBS_DIR/urdfdom_headers
[ -f $TARGET_DIR/lib/liburdfdom_model.a ] || run_cmd build_library_with_cmake urdfdom $LIBS_DIR/urdfdom
[ -f $TARGET_DIR/lib/libiconv.a ] || run_cmd build_library_with_toolchain libiconv $LIBS_DIR/libiconv
[ -f $TARGET_DIR/lib/libxml2.a ] || run_cmd build_library_with_toolchain libxml2 $LIBS_DIR/libxml2
[ -f $TARGET_DIR/lib/libcollada-dom2.4-dp.a ] || run_cmd build_library_with_cmake collada_dom $LIBS_DIR/collada_dom
[ -f $TARGET_DIR/lib/libassimp.a ] || run_cmd build_library_with_cmake assimp $LIBS_DIR/assimp
[ -f $TARGET_DIR/include/eigen3/signature_of_eigen3_matrix_library ] || run_cmd build_library_with_cmake eigen $LIBS_DIR/eigen
[ -f $TARGET_DIR/lib/libqhullstatic.a ] || run_cmd build_library_with_cmake qhull $LIBS_DIR/qhull
[ -f $TARGET_DIR/lib/libyaml-cpp.a ] || run_cmd build_library_with_cmake yaml-cpp $LIBS_DIR/yaml-cpp
[ -f $TARGET_DIR/lib/libflann_cpp_s.a ] || run_cmd build_library_with_cmake flann $LIBS_DIR/flann
[ -f $TARGET_DIR/lib/libpcl_common.a ] || run_cmd build_library_with_cmake pcl $LIBS_DIR/pcl
[ -f $TARGET_DIR/lib/libBulletSoftBody.a ] || run_cmd build_library_with_cmake bullet $LIBS_DIR/bullet
[ -f $TARGET_DIR/lib/libSDL.a ] || run_cmd build_library_with_toolchain sdl $LIBS_DIR/sdl
[ -f $TARGET_DIR/lib/libSDL_image.a ] || run_cmd build_library_with_toolchain sdl-image $LIBS_DIR/sdl-image
[ -f $TARGET_DIR/lib/libogg.a ] || run_cmd build_library_with_toolchain ogg $LIBS_DIR/ogg
[ -f $TARGET_DIR/lib/libvorbis.a ] || run_cmd build_library_with_toolchain vorbis $LIBS_DIR/vorbis
[ -f $TARGET_DIR/lib/libtheora.a ] || run_cmd build_library_with_toolchain theora $LIBS_DIR/theora

echo
echo -e '\e[34mCross-compiling ROS.\e[39m'
echo


if [[ $debugging -eq 1 ]];then
    echo "Build type = DEBUG"
    run_cmd build_catkin_workspace -w $prefix/catkin_ws -p $prefix -b Debug -v $verbose
else
    echo "Build type = RELEASE"
    run_cmd build_catkin_workspace -w $prefix/catkin_ws -p $prefix -b Release -v $verbose
fi

if [[ $samples -eq 1 ]];then
    echo
    echo -e '\e[34mBuilding sample apps.\e[39m'
    echo

    # NOTE(ivanpauno): Samples are built with verbosity, as usually gradle fails when downloading packages.
    # Maybe, an intermediate verbosity option could be used here
    # NOTE(ivanpauno): The example workspace is built using Debug option. The idea is to avoid apk signing.
    run_cmd build_catkin_workspace -w $my_loc/example_workspace -p $my_loc/example_workspace -e $TARGET_DIR -b Debug -v 1
fi
