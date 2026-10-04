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
- **Open:** log in over SSH and do 2c (auto-updates off, no sleep, swap, reboot). Friends who already started the container need `git pull && docker compose up -d`.
