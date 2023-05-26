#!/bin/bash

# Abort script on any failures
set -e

my_loc="$(cd "$(dirname $0)" && pwd)"
echo "my_loc: $my_loc"
# source $my_loc/config.sh
source $my_loc/scripts/utils.sh

if [ $# != 2 ] || [ $1 == '-h' ] || [ $1 == '--help' ]; then
    echo "Usage: $0 library_name library_prefix_path"
    echo "  example: $0 tinyxml /home/user/my_workspace/tinyxml"
    exit 1
fi

echo
echo -e '\e[34mGetting '$1'.\e[39m'
echo

prefix=$(cd $2 && pwd)

if [ $1 == 'assimp' ]; then
    URL=https://github.com/assimp/assimp/archive/v3.1.1.tar.gz
    COMP='gz'
elif [ $1 == 'bfl' ]; then
    URL=https://github.com/ros-gbp/bfl-release/archive/release/indigo/bfl/0.7.0-6.tar.gz
    COMP='gz'
elif [ $1 == 'boost' ]; then
    # URL=https://github.com/ekumenlabs/Boost-for-Android.git
    URL=https://github.com/moritz-wundke/Boost-for-Android.git
    COMP='git'
    HASH='286a548aa9b058402cc88766e818a0218725e163'
elif [ $1 == 'bullet' ]; then
    URL=https://github.com/bulletphysics/bullet3/archive/refs/tags/2.83.6.tar.gz
    COMP='gz'
elif [ $1 == 'bzip2' ]; then
    URL=https://github.com/osrf/bzip2_cmake.git
    COMP='git'
    HASH='0496eaaf58746516124c838e10084951ac4a57e9'
elif [ $1 == 'catkin' ]; then
    URL='-b 0.6.5 https://github.com/ros/catkin.git'
    COMP='git'
elif [ $1 == 'collada_dom' ]; then
    # URL=http://ufpr.dl.sourceforge.net/project/collada-dom/Collada%20DOM/Collada%20DOM%202.4/collada-dom-2.4.0.tgz
    URL=https://github.com/rdiankov/collada-dom/archive/refs/tags/v2.4.4.tar.gz
    COMP='gz'
elif [ $1 == 'console_bridge' ]; then
    # URL=https://github.com/ros/console_bridge.git
    URL=https://github.com/ros/console_bridge/archive/refs/tags/0.3.2.tar.gz
    COMP='gz'
    # COMP='git'
    # HASH='964a9a70e0fc607476e439b8947a36b07322c304'
elif [ $1 == 'curl' ]; then
    # URL=http://curl.haxx.se/download/curl-7.39.0.tar.bz2
    URL=http://curl.haxx.se/download/curl-7.47.0.tar.bz2
    COMP='bz2'
elif [ $1 == 'eigen' ]; then
    # URL=https://github.com/tulku/eigen.git
    # COMP='git'
    URL=https://gitlab.com/libeigen/eigen/-/archive/3.3.5/eigen-3.3.5.tar.gz
    COMP='gz'
elif [ $1 == 'fcl' ]; then
    URL=https://github.com/ros-gbp/fcl-release/archive/release/indigo/fcl/0.3.2-0.tar.gz
    COMP='gz'
elif [ $1 == 'flann' ]; then
    URL=https://github.com/chadrockey/flann_cmake.git
    COMP='git'
    HASH='de1c59fd75479efdf04d3a32988c2fa1061ed7ff'
elif [ $1 == 'libccd' ]; then
    URL=https://github.com/danfis/libccd/archive/v2.0.tar.gz
    COMP='gz'
elif [ $1 == 'libiconv' ]; then
    # URL=http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
    URL=http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.15.tar.gz
    COMP='gz'
elif [ $1 == 'log4cxx' ]; then
    # URL=http://mirrors.sonic.net/apache/logging/log4cxx/0.10.0/apache-log4cxx-0.10.0.tar.gz
    URL=https://archive.apache.org/dist/logging/log4cxx/0.10.0/apache-log4cxx-0.10.0.tar.gz
    COMP='gz'
elif [ $1 == 'libxml2' ]; then
    # URL=ftp://xmlsoft.org/libxml2/libxml2-2.9.1.tar.gz
    URL=ftp://xmlsoft.org/libxml2/libxml2-2.9.7.tar.gz
    COMP='gz'
elif [ $1 == 'lz4' ]; then
    # URL=https://github.com/Cyan4973/lz4/archive/r124.tar.gz
    URL=https://github.com/Cyan4973/lz4/archive/r131.tar.gz
    COMP='gz'
elif [ $1 == 'octomap' ]; then
    URL=https://github.com/OctoMap/octomap/archive/v1.6.8.tar.gz
    COMP='gz'
elif [ $1 == 'ogg' ]; then
    URL=http://downloads.xiph.org/releases/ogg/libogg-1.3.3.tar.gz
    COMP='gz'
elif [ $1 == 'opencv' ]; then
    URL=https://github.com/Itseez/opencv/archive/2.4.9.tar.gz
    COMP='gz'
elif [ $1 == 'orocos_kdl' ]; then
    URL=https://github.com/smits/orocos-kdl-release/archive/release/indigo/orocos_kdl/1.3.0-0.tar.gz
    COMP='gz'
elif [ $1 == 'pcl' ]; then
    # URL=https://github.com/chadrockey/pcl.git
    URL=https://github.com/PointCloudLibrary/pcl/archive/pcl-1.8.1.tar.gz
    # COMP='git'
    COMP='gz'
elif [ $1 == 'pcrecpp' ]; then
    URL=https://github.com/brianb/pcre-7.8.git
    COMP='git'
elif [ $1 == 'poco' ]; then
    # URL=http://pocoproject.org/releases/poco-1.6.1/poco-1.6.1.tar.gz
    URL=http://pocoproject.org/releases/poco-1.8.0/poco-1.8.0.tar.gz
    COMP='gz'
elif [ $1 == 'qhull' ]; then
    # URL=http://www.qhull.org/download/qhull-2012.1-src.tgz
    URL=http://www.qhull.org/download/qhull-2015-src-7.2.0.tgz
    COMP='gz'
elif [ $1 == 'sdl' ]; then
    URL=https://www.libsdl.org/release/SDL-1.2.15.tar.gz
    COMP='gz'
elif [ $1 == 'sdl-image' ]; then
    URL=http://hg.libsdl.org/SDL_image/archive/d46c630f2cd6.tar.gz
    COMP='gz'
elif [ $1 == 'theora' ]; then
    URL=http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.bz2
    COMP='bz2'
elif [ $1 == 'tinyxml' ]; then
    URL=https://github.com/chadrockey/tinyxml_cmake
    COMP='git'
    HASH='cbacc92a6e9b5359567336776b9d9eaf92d88355'
elif [ $1 == 'tinyxml2' ]; then
    URL=https://github.com/leethomason/tinyxml2/archive/refs/tags/7.0.1.tar.gz
    COMP='gz'
elif [ $1 == 'urdfdom' ]; then
    # URL=https://github.com/ros/urdfdom.git
    # COMP='git'
    # HASH='c4ac03caf55369c64c61605b78f1b6071bb4acce'
    URL=https://github.com/ros/urdfdom/archive/refs/tags/0.4.2.tar.gz
    COMP='gz'
elif [ $1 == 'urdfdom_headers' ]; then
    # URL=https://github.com/ros/urdfdom_headers.git
    # COMP='git'
    # HASH='9aed7256e06d62935966de2a9bc9ddfac96e7a85'
    URL=https://github.com/ros/urdfdom_headers/archive/refs/tags/0.4.2.tar.gz
    COMP='gz'
elif [ $1 == 'uuid' ]; then
    URL=https://github.com/chadrockey/uuid_cmake
    COMP='git'
    HASH='2e7e31f12397474c9465acbae868d13170b3337b'
elif [ $1 == 'vorbis' ]; then
    URL=http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.6.tar.gz
    COMP='gz'
elif [ $1 == 'yaml-cpp' ]; then
    # URL=https://github.com/ekumenlabs/yaml-cpp.git
    # COMP='git'
    URL=https://github.com/jbeder/yaml-cpp/archive/yaml-cpp-0.6.2.tar.gz
    COMP='gz'
elif [ $1 == 'rospkg' ]; then
    URL=https://github.com/ros-infrastructure/rospkg.git
    COMP='git'
    HASH='93b1b72f256badf22ccc926b22646f2e83b720fd'
fi

if [ $COMP == 'gz' ]; then
    download_gz $URL $prefix
elif [ $COMP == 'bz2' ]; then
    download_bz2 $URL $prefix
elif [ $COMP == 'git' ];then
    git clone $URL $prefix/$1
fi

if [ $1 == 'boost' ]; then
    cd $prefix/boost
    ./build-android.sh $ANDROID_NDK --boost=1.53.0
elif [ -v HASH ]; then
    cd $prefix/$1
    git checkout $HASH
elif [ $1 == 'bullet' ]; then
    mv $prefix/bullet3-2.83.6 $prefix/bullet
elif [ $1 == 'collada_dom' ]; then
    mv $prefix/collada-dom-2.4.4 $prefix/collada_dom
elif [ $1 == 'eigen' ]; then
    mv $prefix/eigen-3.3.5 $prefix/eigen
elif [ $1 == 'lz4' ]; then
    mv $prefix/lz4-r131 $prefix/lz4
elif [ $1 == 'poco' ]; then
    mv $prefix/poco-1.8.0 $prefix/poco
elif [ $1 == 'tinyxml2' ]; then
    mv $prefix/tinyxml2-7.0.1 $prefix/tinyxml2
fi
