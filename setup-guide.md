# TurtleBot3 Setup Guide (ROS 2 Jazzy, Ubuntu 24.04)

**Your setup:** TurtleBot3 **Burger**, **Raspberry Pi 4 Model B** + **OpenCR 1.0**, reflashed headless (no HDMI).
Robot: **Ubuntu Server 24.04 + ROS 2 Jazzy**. Laptop: **Ubuntu 26.04** running **ROS 2 Jazzy in Docker** (option B).

Based on the ROBOTIS e-manual Quick Start, Jazzy tab: https://emanual.robotis.com/docs/en/platform/turtlebot3/quick-start/
If a command here disagrees with the e-manual, trust the e-manual.

---

## 1. Remote PC (your laptop)

Jazzy only ships packages for Ubuntu 24.04. Pick one option.

### Option A: laptop on Ubuntu 24.04 (reinstall or dual-boot)
1. Install **ROS 2 Jazzy Desktop**: https://docs.ros.org/en/jazzy/Installation/Ubuntu-Install-Debs.html
2. Install Cartographer and Nav2:
   ```bash
   sudo apt install ros-jazzy-cartographer ros-jazzy-cartographer-ros \
     ros-jazzy-navigation2 ros-jazzy-nav2-bringup python3-colcon-common-extensions
   ```
3. Build the TurtleBot3 packages:
   ```bash
   source /opt/ros/jazzy/setup.bash
   mkdir -p ~/turtlebot3_ws/src && cd ~/turtlebot3_ws/src
   git clone -b jazzy https://github.com/ROBOTIS-GIT/DynamixelSDK.git
   git clone -b jazzy https://github.com/ROBOTIS-GIT/turtlebot3_msgs.git
   git clone -b jazzy https://github.com/ROBOTIS-GIT/turtlebot3.git
   cd ~/turtlebot3_ws && colcon build --symlink-install
   ```
4. Environment (laptop and robot must use the **same** `ROS_DOMAIN_ID`):
   ```bash
   echo 'source /opt/ros/jazzy/setup.bash' >> ~/.bashrc
   echo 'source ~/turtlebot3_ws/install/setup.bash' >> ~/.bashrc
   echo 'export ROS_DOMAIN_ID=30 # TURTLEBOT3' >> ~/.bashrc
   echo 'export TURTLEBOT3_MODEL=burger' >> ~/.bashrc
   source ~/.bashrc
   ```

### Option B (your choice): keep Ubuntu 26.04, run Jazzy in Docker
The `Dockerfile` and `compose.yaml` in this repo build ROS 2 Jazzy + the TurtleBot3, Cartographer and Nav2 packages into one image. With host networking the container talks to the robot exactly like a native install.

1. Install Docker and Compose, and allow your user to run Docker (log out and back in afterwards):
   ```bash
   sudo apt install docker.io docker-compose-v2
   sudo usermod -aG docker $USER
   ```
2. Clone this repo to your laptop as `~/tb3`, then build and start the container. The first build downloads a few GB:
   ```bash
   cd ~/tb3
   docker compose up -d --build
   ```
3. Let the container open GUI windows (RViz). Run once per login: `xhost +local:docker`
4. Open a shell in the container, as many times as you need terminals:
   ```bash
   docker compose exec tb3 bash
   ```
   ROS is already sourced, with `ROS_DOMAIN_ID=30` and `TURTLEBOT3_MODEL=burger` set.
5. Maps saved to `/root/maps` in the container appear in `~/tb3/maps` on the laptop. The container restarts by itself after a reboot; `docker compose down` stops it.

Every "on the laptop" command later in this guide runs inside the container (`docker compose exec tb3 bash`), or in your normal shell if you went with option A.

## 2. Raspberry Pi 4 (the robot's SBC)

You need a microSD card (16 GB+) and a card reader. **No HDMI needed:** the Pi joins your Wi-Fi on first boot and you log in over SSH. Pi and laptop must be on the **same Wi-Fi network**.

### 2a. Flash Ubuntu Server 24.04 headless with Raspberry Pi Imager
1. Install **Raspberry Pi Imager**: `sudo apt install rpi-imager` (or from https://www.raspberrypi.com/software/)
2. *Choose Device*: **Raspberry Pi 4**. *Choose OS*: **Other general-purpose OS → Ubuntu → Ubuntu Server 24.04.x LTS (64-bit)**. *Choose Storage*: your SD card.
3. Click **Next → Edit Settings** (OS customisation) and set:
   - **Hostname:** `turtlebot`
   - **Username / password:** e.g. `ubuntu` / a password you'll remember
   - **Configure wireless LAN:** your Wi-Fi SSID, password and **Wireless LAN country**
   - **Services tab:** tick **Enable SSH → Use password authentication**
4. Write the card, put it in the Pi and power the robot on.
5. Wait **3 to 5 minutes**. First boot runs cloud-init and may reboot once before Wi-Fi comes up. If it never appears, power-cycle once more.

### 2b. Find the Pi's IP and SSH in
Try these in order on the laptop:
1. `ssh ubuntu@turtlebot.local`
2. Your router's admin page, connected devices / DHCP clients, look for `turtlebot`
3. Scan your subnet (adjust to your network): `sudo nmap -sn 192.168.1.0/24`
4. Phone hotspot: use your hotspot's credentials in step 2a; the hotspot screen lists connected devices and IPs.
   **iPhone:** the default hotspot name `Name’s iPhone` uses a curly `’`, and typing a straight `'` in the Imager means the Pi never connects. Rename the phone without an apostrophe (Settings → General → About → Name) before flashing, and turn on **Maximize Compatibility**.

**Fallback:** plug an Ethernet cable from the Pi into your router, SSH in over that, then fix Wi-Fi in `/etc/netplan/50-cloud-init.yaml` and run `sudo netplan apply`.

### 2c. Prepare the Pi (over SSH)
```bash
# Stop automatic updates from locking apt: set both values to "0"
sudo nano /etc/apt/apt.conf.d/20auto-upgrades
# Stop the Pi from sleeping
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
# Add 2 GB swap so the build doesn't run out of memory (essential on 2 GB Pis, harmless otherwise)
sudo fallocate -l 2G /swapfile && sudo chmod 600 /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
sudo reboot
```

### 2d. Install ROS 2 Jazzy + TurtleBot3 on the Pi
1. Install **ROS 2 Jazzy ros-base** (not desktop): https://docs.ros.org/en/jazzy/Installation/Ubuntu-Install-Debs.html
2. Build the robot packages:
   ```bash
   sudo apt install python3-argcomplete python3-colcon-common-extensions libboost-system-dev build-essential \
     ros-jazzy-hls-lfcd-lds-driver ros-jazzy-turtlebot3-msgs ros-jazzy-dynamixel-sdk ros-jazzy-xacro libudev-dev
   mkdir -p ~/turtlebot3_ws/src && cd ~/turtlebot3_ws/src
   git clone -b jazzy https://github.com/ROBOTIS-GIT/turtlebot3.git
   git clone -b jazzy https://github.com/ROBOTIS-GIT/ld08_driver.git
   git clone -b jazzy https://github.com/ROBOTIS-GIT/coin_d4_driver
   cd ~/turtlebot3_ws/src/turtlebot3 && rm -r turtlebot3_cartographer turtlebot3_navigation2
   cd ~/turtlebot3_ws
   echo 'source /opt/ros/jazzy/setup.bash' >> ~/.bashrc && source ~/.bashrc
   colcon build --symlink-install --parallel-workers 1
   echo 'source ~/turtlebot3_ws/install/setup.bash' >> ~/.bashrc && source ~/.bashrc
   ```

### 2e. Robot environment
```bash
# USB rules so the OpenCR shows up correctly
sudo cp `ros2 pkg prefix turtlebot3_bringup`/share/turtlebot3_bringup/script/99-turtlebot3-cdc.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules && sudo udevadm trigger

echo 'export ROS_DOMAIN_ID=30 # TURTLEBOT3' >> ~/.bashrc
echo 'export TURTLEBOT3_MODEL=burger' >> ~/.bashrc
# Check the sticker on your LiDAR: LDS-01, LDS-02 or LDS-03
echo 'export LDS_MODEL=LDS-02' >> ~/.bashrc
source ~/.bashrc
```

## 3. OpenCR firmware (run on the Pi, OpenCR plugged in via USB)

```bash
sudo dpkg --add-architecture armhf
sudo apt update && sudo apt install libc6:armhf
export OPENCR_PORT=/dev/ttyACM0
export OPENCR_MODEL=burger
rm -rf ./opencr_update.tar.bz2
wget https://github.com/ROBOTIS-GIT/OpenCR-Binaries/raw/master/turtlebot3/ROS2/latest/opencr_update.tar.bz2
tar -xvf opencr_update.tar.bz2
cd ./opencr_update && ./update.sh $OPENCR_PORT $OPENCR_MODEL.opencr
```
**Check it worked:** with the robot on the floor and the battery on, press **SW1** on the OpenCR (robot drives forward ~30 cm) and **SW2** (robot rotates 180°).

If the upload fails: hold **PUSH SW2**, tap **RESET**, release SW2 (enters bootloader), then rerun `update.sh`.

## 4. Bring up and drive

On the **Pi** (via SSH):
```bash
ros2 launch turtlebot3_bringup robot.launch.py
```
On the **laptop**, in a new terminal:
```bash
ros2 topic list        # you should see /scan, /odom, /cmd_vel ...
ros2 run turtlebot3_teleop teleop_keyboard
```
W/A/S/D/X to drive, space or S to stop. `ros2 launch turtlebot3_bringup rviz2.launch.py` shows the robot and LiDAR in RViz.

## 5. Next: SLAM and navigation (laptop)

```bash
# Build a map while driving with teleop
ros2 launch turtlebot3_cartographer cartographer.launch.py
ros2 run nav2_map_server map_saver_cli -f ~/map      # Docker: -f /root/maps/map

# Navigate on the saved map (set 2D Pose Estimate, then Nav2 Goal in RViz)
ros2 launch turtlebot3_navigation2 navigation2.launch.py map:=$HOME/map.yaml   # Docker: map:=/root/maps/map.yaml
```

## Common problems

| Symptom | Likely cause / fix |
|---|---|
| Laptop can't see robot topics | `ROS_DOMAIN_ID` differs, different Wi-Fi/subnet, or router blocks multicast. Try both on a phone hotspot to test. If still stuck, set `export RMW_IMPLEMENTATION=rmw_fastrtps_cpp` on both. |
| RViz in Docker stuck on a small splash window; log shows `failed to load driver: iris` / `Failed to query drm device` | The container can't see the GPU. `compose.yaml` passes `/dev/dri` through; if you edited it, restore that and run `docker compose up -d`. |
| `permission denied ... docker.sock` even after logging out and back in | Your user's systemd manager survives logout when lingering is on (`loginctl show-user $USER -p Linger`), so the new `docker` group isn't picked up. Reboot. |
| GUI won't open from Docker (`cannot open display`) | Run `xhost +local:docker` on the laptop and check `echo $DISPLAY` inside the container is set. |
| `/dev/ttyACM0` not found | OpenCR not powered/plugged in, or udev rules not reloaded. Check `ls /dev/ttyACM*`. |
| LiDAR not spinning / no `/scan` | Wrong `LDS_MODEL`, or LiDAR USB cable loose. |
| Robot jerky or stops | Battery low (OpenCR beeps), or Wi-Fi latency. |
| `colcon build` freezes on the Pi | Out of RAM: keep `--parallel-workers 1` and make sure the swap from 2c is on (`free -h`). |
