#!/bin/bash

catkin_ws=$1
cd $catkin_ws/src
git clone https://github.com/CCNYRoboticsLab/scan_tools.git scan_tools
cd scan_tools
git checkout indigo
if [[ -d laser_scan_matcher ]]; then
    rm -r laser_scan_matcher
fi

