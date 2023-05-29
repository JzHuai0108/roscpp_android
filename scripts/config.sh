# Configures environment variables required for other scripts to work properly.
# Always source this file before using the scripts.

# Configure the Android NDK and toolchain
export ANDROID_ABI=arm64-v8a # armeabi-v7a
export ANDROID_STL=c++_static       # or c++_shared, see https://developer.android.com/ndk/guides/cpp-support
export ANDROID_PLATFORM=android-24
# android 7.0 is android api level 24
# Enable this value for debug build
#CMAKE_BUILD_TYPE=Debug
export CMAKE_BUILD_TYPE=Release

# Define the number of simultaneous jobs to trigger for the different
# tasks that allow it. Use the number of available processors in the
# system.
export PARALLEL_JOBS=$(nproc)

# Export common paths
export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export BASE_DIR=$SCRIPT_DIR/..
