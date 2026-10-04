# Project log

Newest entries first. Each entry: date, who, what changed, and what's still open.

---

## 2026-10-04 — Jimmy
- Set up this repo with `CLAUDE.md`, `logs.md` and `.gitignore` (ignores `maps/` and colcon build output), and published it as a private GitHub repo: https://github.com/koustubh1012/tb3
- Updated `setup-guide.md` 1B to point to the repo root instead of a `docker/` folder, and to say "clone" instead of "copy".
- Guide section 1B on the laptop (Ubuntu 26.04):
  - Installed `docker.io` + `docker-compose-v2` and added the user to the `docker` group.
  - Started `sudo docker compose up -d --build`, since the group needs a re-login to take effect.
- **Open:** confirm the build finished and `tb3` is running, re-login, `xhost +local:docker`, test `rviz2` in the container. Then start section 2 (flash the Pi).
