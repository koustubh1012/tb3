# ROS 2 Jazzy + TurtleBot3 remote-PC tools, for laptops not running Ubuntu 24.04
FROM osrf/ros:jazzy-desktop-full

RUN apt-get update && apt-get install -y --no-install-recommends \
      ros-jazzy-cartographer ros-jazzy-cartographer-ros \
      ros-jazzy-navigation2 ros-jazzy-nav2-bringup \
      python3-colcon-common-extensions git nano \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /root/turtlebot3_ws/src
RUN git clone -b jazzy --depth 1 https://github.com/ROBOTIS-GIT/DynamixelSDK.git \
 && git clone -b jazzy --depth 1 https://github.com/ROBOTIS-GIT/turtlebot3_msgs.git \
 && git clone -b jazzy --depth 1 https://github.com/ROBOTIS-GIT/turtlebot3.git

WORKDIR /root/turtlebot3_ws
RUN apt-get update && rosdep update --rosdistro jazzy \
 && rosdep install --from-paths src --ignore-src -y --rosdistro jazzy \
 && rm -rf /var/lib/apt/lists/* \
 && . /opt/ros/jazzy/setup.sh && colcon build --symlink-install

RUN echo 'source /opt/ros/jazzy/setup.bash' >> /root/.bashrc \
 && echo 'source /root/turtlebot3_ws/install/setup.bash' >> /root/.bashrc

ENV ROS_DOMAIN_ID=30 \
    TURTLEBOT3_MODEL=burger
WORKDIR /root
CMD ["bash"]
