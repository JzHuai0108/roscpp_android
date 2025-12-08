#!/usr/bin/env bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
REPO_ROOT=$SCRIPTPATH/../
IMAGE=menny/android_ndk

DOCKEROPTS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --help)
      # print usage
      echo "Usage: $0 [DOCKER OPTIONS] [-- [COMMAND]]"
      echo
      echo "Docker options:"
      docker run --help | tail -n +7
      exit 0
      ;;
    --)
      # end-of-options: all arguments after the -- will be interpreted as a command to run inside the container.
      shift
      break
      ;;
    *)
      # collect docker options
      DOCKEROPTS+=("$1")
      shift
      ;;
  esac
done

set -x
docker run \
  -v ${REPO_ROOT}:/opt/ros_android \
  -v ~/docker-share:/docker \
  --privileged \
  -it \
  "${DOCKEROPTS[@]}" \
  ${IMAGE} "$@"
