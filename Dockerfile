FROM ubuntu:22.04

WORKDIR /app

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update

### ROS 2
# Set locale
RUN apt-get install -y locales
RUN locale-gen en_US en_US.UTF-8
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8

# Setup Sources
RUN apt-get install -y software-properties-common
RUN add-apt-repository universe

RUN apt-get install -y curl
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Install ROS 2 packages
RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get install -y ros-humble-desktop
RUN apt-get install -y ros-humble-ros-base
RUN apt-get install -y ros-dev-tools

### Crazyswarm2
# Dependencies
RUN apt-get install -y libboost-program-options-dev libusb-1.0-0-dev
RUN apt-get install -y python3-pip 
RUN pip3 install rowan nicegui

# Motion Capture
RUN apt-get install -y ros-humble-motion-capture-tracking

# CFlib
RUN pip3 install cflib transforms3d
RUN apt-get install -y ros-humble-tf-transformations

# Git
RUN apt-get install -y git

# Cloning crazyswarm2
RUN mkdir -p ros2_ws/src
WORKDIR /app/ros2_ws/src
RUN git clone https://github.com/IMRCLab/crazyswarm2 --recursive

# Building crazyswarm2 with custom build script to source ROS 2 before building
WORKDIR /app/ros2_ws

ADD build.sh /app/ros2_ws
RUN chmod a+x ./build.sh
RUN bash -c ./build.sh

WORKDIR /app
RUN mkdir ws

