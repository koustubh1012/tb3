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
- **Open:** reboot so `docker` works without sudo, check the ROS packages inside the container, `xhost +local:docker`, test `rviz2`. Then start section 2 (flash the Pi).
