#!/bin/bash
# Builds a target library using a standalone toolchain.
# See help for required positional arguments.
# 
# Required environment variables:
# - SCRIPT_DIR: where utility scripts are located.

# Abort script on any failures
set -e

source $SCRIPT_DIR/utils.sh

if [ $# != 2 ] || [ "$1" == '-h' ] || [ "$1" == '--help' ]; then
    echo "Usage: $0 library_name library_source_dir"
    echo "  example: $0 libxml2 /home/user/ros_android/output/libs/libxml2-2.9.1"
    exit 1
fi

prefix=$(cd $2 && pwd)

cd $prefix

# Create a stand alone version of the android toolchain
echo
echo -e '\e[34mBuilding '"$1"'.\e[39m'
echo

[ "$TARGET_DIR" = "" ] && die 'could not find target basedir. Please set $TARGET_DIR environment variable.'

if [ "armeabi-v7a" = $ANDROID_ABI ]; then
    arch="arm"
elif [ "arm64-v8a" = $ANDROID_ABI ]; then
    arch="arm64"
fi

if [ ! -d toolchain/ ]; then
  $ANDROID_NDK_HOME/build/tools/make-standalone-toolchain.sh --install-dir=./toolchain --arch=$arch --platform=${ANDROID_PLATFORM} --stl=${ANDROID_STL}
fi
export PATH=$PATH:$prefix/toolchain/bin

# Set --host: The system where built programs and libraries will run.
# (https://www.gnu.org/software/automake/manual/html_node/Cross_002dCompilation.html)
build=`uname -m`-linux
# host=$(basename $prefix/toolchain/*-linux-android)
host="arm-linux-androideabi"  # corresponding to armeabi-v7a.
echo "build $build host $host"

# General options to pass to ./configure script
configure_options="--prefix=$TARGET_DIR --disable-shared --enable-static --build=${build} --host=${host}"

# Overwrite/extend for specific packages
if [ "$1" == 'poco' ]; then
    configure_options="--config=Android_static --no-samples --no-tests"
elif [ "$1" == 'curl' ]; then
    configure_options="$configure_options --without-ssl --disable-tftp --disable-sspi --disable-ipv6 --disable-ldaps --disable-ldap --disable-telnet --disable-pop3 --disable-ftp --disable-imap --disable-smtp --disable-pop3 --disable-rtsp --disable-ares --without-ca-bundle --disable-warnings --disable-manual --without-nss --without-random"
elif [ "$1" == 'libxml2' ]; then
    configure_options="$configure_options --without-python"
elif [ "$1" == 'sdl' ]; then
    # Update old config.sub and config.guess
    cp /usr/share/automake*/config* build-scripts/
    # Update ./configure
    ./autogen.sh
elif [ "$1" == 'sdl-image' ]; then
    # Update old config.sub and config.guess
    cp /usr/share/automake*/config* .
    # Update ./configure
    ./autogen.sh
    # Export sdl-config file location
    export SDL_CONFIG=$prefix/../../target/bin/sdl-config
elif [ "$1" == 'vorbis' ]; then
    # Specify OGG location
    # TODO(ivanpauno): Check why --with-ogg=prefix isn't working.
    export OGG_CFLAGS=-I${TARGET_DIR}/include
    export OGG_LIBS=-L${TARGET_DIR}/lib
    # Regenerate and call ./configure
    ./autogen.sh ${configure_options}
elif [ "$1" == 'theora' ]; then
    # Update old config.sub and config.guess
    cp /usr/share/automake*/config* .
    # Disable building examples
    configure_options="$configure_options --disable-examples"
    # Specify OGG and vorbis location
    export OGG_CFLAGS=-I${TARGET_DIR}/include
    export OGG_LIBS=-L${TARGET_DIR}/lib
    # Regenerate and call ./configure
    ./autogen.sh ${configure_options}
fi

# Configure and build
./configure ${configure_options}
make -j$PARALLEL_JOBS -l$PARALLEL_JOBS V=1

# Install
if [ $1 == 'poco' ]; then
    mkdir -p $TARGET_DIR/lib
    cd $TARGET_DIR/lib
    cp $prefix/lib/Android/$ANDROID_ABI/lib*.a ./
    mkdir -p ../include && cd ../include
    cp -r $prefix/Foundation/include/Poco ./
else
    make install
fi
