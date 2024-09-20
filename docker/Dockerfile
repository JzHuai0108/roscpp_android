FROM ros:kinetic-ros-core-xenial
MAINTAINER Julian Cerruti <jcerruti@ekumenlabs.com>
MAINTAINER Gary Servin <gary@ekumenlabs.com>
MAINTAINER Juan Ignacio Ubeira <jubeira@ekumenlabs.com>

# Install basic tools
RUN apt-get update && apt-get install -y --allow-unauthenticated wget git unzip tmux python-catkin-tools python-lxml automake autoconf

# Install Android NDK
WORKDIR /opt/android/sdk
RUN wget https://dl.google.com/android/repository/android-ndk-r23c-linux.zip
RUN unzip android-ndk-r23c-linux.zip -d /opt/android/sdk

# Set-up environment
ENV ANDROID_NDK_HOME /opt/android/sdk/android-ndk-r23c

# Install g++ to avoid "CMAKE_CXX_COMPILER-NOTFOUND was not found." error
RUN apt-get update && apt-get install -y g++ cmake make clang

# Install Android SDK
ENV ANDROID_HOME /opt/android/sdk
RUN apt-get update && apt-get install -y openjdk-8-jdk
# The latest version will always be 4333796 because sdk-tools is deprecated.
# If you want to use the new approach, use commandlinetools-linux instead :)

RUN wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
RUN unzip sdk-tools-linux-4333796.zip -d /opt/android/sdk

# THe latest command line tools caused java runtime library errors.
# RUN wget https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip
# RUN unzip commandlinetools-linux-10406996_latest.zip -d /opt/android/sdk
# RUN mv /opt/android/sdk/cmdline-tools /opt/android/sdk/tools

RUN yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses
RUN yes | $ANDROID_HOME/tools/bin/sdkmanager "build-tools;26.0.2" "build-tools;28.0.2" "build-tools;29.0.2" "build-tools;33.0.2" "platform-tools" "platforms;android-26" "platforms;android-28" "platforms;android-31" "cmake;3.10.2.4988404" --sdk_root=/opt/android/sdk
ENV PATH /opt/android/sdk/tools:/opt/android/sdk/platform-tools:/opt/android/sdk/cmake/3.10.2.4988404/bin:$PATH

# Install Python libraries
RUN apt-get install python-lxml -y
RUN apt-get install libtool -y
RUN apt-get install python-wstool -y --allow-unauthenticated
RUN apt-get install libxext-dev -y  # This is a header only library needed by the SDL video module in ndk-r21e and r23c.
RUN apt-get install vim -y  # for debugging within a docker container.

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/

# Use ccache
RUN apt-get update && apt-get install -y ccache
ENV USE_CCACHE 1
ENV NDK_CCACHE /usr/bin/ccache
ENV CCACHE_DIR /opt/roscpp_output/ccache
ENV PATH /usr/lib/ccache:$PATH

# Clear entrypoint (do not source /opt/ros/kinetic)
ENTRYPOINT []

VOLUME /opt/ros_android
WORKDIR /opt/ros_android
CMD ["bash"]
