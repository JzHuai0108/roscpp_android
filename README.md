These scripts will (hopefully) help you build static libraries
for tf2 for android and setup a sample application.

You will need android SDK installed and the 'android' program
location in the $PATH.

An updated version of roscpp_android for ros kinetic is at [here](https://github.com/Intermodalics/ros_android).

INSTALL in a docker of ubuntu 14 + ros indigo
-------------------------------------------
1. First run ./do_docker.sh. This will echo the used local paths in docker.
2. If step 1 is successful, then pass. Otherwise, under a poor network, run local_download.sh to download necessary libraries.
Note set my_loc and prefix accordingly.
3. run do_docker.sh several times until success with the below messages.

```
-post-build:

debug:

BUILD SUCCESSFUL
Total time: 3 seconds

done.
summary of what just happened:
  target/      was used to build static libraries for ros software
    include/   contains headers
    lib/       contains static libraries
  roscpp_android_ndk/     is a NDK sub-project that can be imported into an NDK app
  sample_app/  is an example of such an app, a native activity
  sample_app/bin/sample_app-debug.apk  is the built apk, it implements a subscriber and a publisher
  move_base_sample_app/  is an example app that implements the move_base node
  move_base_app/bin/move_base_app-debug.apk  is the built apk for the move_base example
  pluginlib_sample_app/  is an example of an application using pluginlib
  pluginlib_sample_app/bin/pluginlib_sample_app-debug.apk  is the built apk

```
If an error persists, you may go inside the docker to debug it
```
my_loc=/media/jhuai/docker/roscpp_android_ndk/roscpp_android
output_path=/media/jhuai/docker/roscpp_android_ndk/roscpp_android/output
sudo docker run --rm=true -t -v $my_loc:/opt/roscpp_android -v $output_path:/opt/roscpp_output -i ekumenlabs/rosndk
# Then in docker, run
/opt/roscpp_android/do_everything.sh /opt/roscpp_output
```


INSTALL
-------

Source ROS (for python tools):

    source /opt/ros/hydro/setup.bash

The `do_everything.sh` script will call all the other scripts
sequentially, you just have to give it a prefix path:

    ./do_everything.sh /path/to/workspace

YOU WILL PROBABLY HAVE TO RUN THIS MULTIPLE TIMES DUE TO PTHREAD LINKING.

You can also run each script individually, most of them have
a minimalistic help string to give you an idea of their parameters.

When finished, the script will give you a few lines of what it did.
If everything went fine, you will be able to do the following:

    cd /path/to/workspace/sample_app
    ant debug

This will build the app. If you want to install it, run the following:

    ant debug install

This will install the app onto a virtual android device running in the
emulator.

To follow what the app does, you will need to read the log. The sdk has
a tool called `adb` located in `$SDK/platform-tools/`, you can follow the
log by running:

    $SDK/platform-tools/adb logcat

Good luck!
