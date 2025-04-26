# android_ndk docker image

This image contains all the basic tools required to cross compile the ROS packages and its dependencies.

To build the image, run `build.sh`. To run the image, run `run.sh`. `ros_android` folder and all its contents will be mapped to `/opt/ros_android` inside the docker container. 

Once inside the container, place the output in a child directory of `/opt/ros_android` to be able to access it from your host computer.

## Update the docker image

Occasionally, you may need to add new packages to your Docker image. To do so:

1. Start a container from the existing image (e.g., android_ndk) in terminal A:

```bash
docker run -it android_ndk /bin/bash
```

2. Install the desired package inside the container (e.g., flex) in terminal A:

```bash
apt update && apt install -y flex
```

3. In another terminal B, commit the container to create a new image (e.g., android_ndk_flex):

```bash
docker commit <container_id> android_ndk_flex
```

4. Exit the container from terminal A, and replace the old image (optional) in terminal A or B:

```bash
docker rmi android_ndk
docker tag android_ndk_flex android_ndk
```

You now have an updated android_ndk image with the new package included.
