# Project log

Newest entries first. Each entry: date, who, what changed, and what's still open.

---

## 2026-10-04 — Jimmy
- Set up this repo with `CLAUDE.md`, `logs.md` and `.gitignore` (ignores `maps/` and colcon build output), and published it as a private GitHub repo: https://github.com/koustubh1012/tb3
- Updated `setup-guide.md` 1B to point to the repo root instead of a `docker/` folder, and to say "clone" instead of "copy".
- Guide section 1B on the laptop (Ubuntu 26.04):
  - Installed `docker.io` + `docker-compose-v2` and added the user to the `docker` group.
  - Started `sudo docker compose up -d --build`, since the group needs a re-login to take effect.
- Build finished; `tb3` container (image `tb3-jazzy`) is up.
- Gotcha: logging out did **not** apply the new `docker` group. User lingering is enabled (`loginctl show-user $USER -p Linger`), so the systemd user manager from boot survives logout and terminals inherit the old groups. Fix: reboot. Until then, use `sudo docker ...`.
- Verified inside the container: `ROS_DOMAIN_ID=30`, `TURTLEBOT3_MODEL=burger`, `DISPLAY=:0`; turtlebot3_*, cartographer_ros and nav2_bringup packages present.
- Rebooted: `docker` now works without sudo; `tb3` came back up on its own.
- Bug fixed: RViz hung on its splash screen (`failed to load driver: iris`) because the container had no GPU access. Added `devices: /dev/dri` to `compose.yaml`; RViz now runs with OpenGL 4.6 on the Intel iGPU. Added this and the lingering gotcha to the guide's Common problems table.
- **Section 1B done.**
- Section 2a/2b: flashed Ubuntu Server 24.04 (hostname `turtlebot`, SSH password auth). First flash never joined Wi-Fi: the iPhone hotspot name had a curly apostrophe. Renamed the phone hotspot to `koustubhiPhone` and reflashed; the Pi joined at `172.20.10.7`, `turtlebot.local` resolves, SSH port open. Added the apostrophe gotcha to guide 2b.
- Pi: Ubuntu 24.04.5 aarch64, 4 GB RAM, 16 GB SD (12 GB free). Section 2c done: auto-updates off, sleep targets masked, 2 GB `/swapfile` in fstab, verified after reboot.
- Section 2d done: ROS 2 Jazzy ros-base on the Pi; `colcon build` of the robot workspace finished 8/8 packages in 4m37s.
  - Bug fixed in guide: the build failed on missing `urdf`, because ros-base plus the guide's apt list isn't enough. Added a `rosdep install` step to 2d. `rosdep` itself was missing because `ros-dev-tools` hadn't been installed, so the guide now says to install it explicitly (not Ubuntu's `python3-rosdep2`).
- 2e in progress: `ROS_DOMAIN_ID=30` and `TURTLEBOT3_MODEL=burger` are in the Pi's `~/.bashrc`.
  - Found that `ros-jazzy-ros-base` had never actually installed (`ros2: command not found`). Installing it failed: `liblz4-dev`/`libzstd-dev` unmet dependencies. Cause: the Pi image's `ubuntu.sources` lacked `noble-updates`. Added it, ran `full-upgrade`, and ros-base installed. Added a check to guide 2c and two rows to Common problems.
- **Open:** reboot the Pi (core packages upgraded), copy udev rules, set `LDS_MODEL` (check the LiDAR sticker), then section 3 (OpenCR firmware). Friends who already started the container need `git pull && docker compose up -d`.
