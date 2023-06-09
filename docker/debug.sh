# To ease debugging the cross compiling process, there are some handy commands.
# To start the docker container
docker run -v /media/jhuai/docker/roscpp_android_ndk/ros_android:/opt/ros_android -it android_ndk /bin/bash

# To debug within the container
prefix=/opt/ros_android/output
./build_catkin_workspace.sh -w $prefix/catkin_ws -p $prefix -b Release -v 1

