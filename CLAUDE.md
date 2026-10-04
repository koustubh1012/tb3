# TurtleBot3 project

Shared repo for getting a TurtleBot3 **Burger** (Raspberry Pi 4 + OpenCR 1.0) running on **ROS 2 Jazzy**, then doing SLAM and navigation.

## Layout
- `setup-guide.md` — the step-by-step setup guide (laptop, Pi, OpenCR firmware, bringup, SLAM/Nav2). Follows the ROBOTIS e-manual Jazzy tab; if they disagree, the e-manual wins.
- `Dockerfile`, `compose.yaml` — ROS 2 Jazzy + TurtleBot3/Cartographer/Nav2 image for laptops not on Ubuntu 24.04 (guide section 1B). Image `tb3-jazzy`, container `tb3`, host networking.
- `maps/` — bind-mounted to `/root/maps` in the container. Git-ignored; owned by root because the container creates it.
- `logs.md` — running project log. See below.

## Machines
- **Laptop (remote PC):** Ubuntu 26.04, ROS runs only inside the `tb3` container. Laptop-side ROS commands go through `docker compose exec tb3 bash`.
- **Robot (Pi):** Ubuntu Server 24.04 + ROS 2 Jazzy ros-base, hostname `turtlebot`, reached over SSH (`ubuntu@turtlebot.local`).
- Both use `ROS_DOMAIN_ID=30`, `TURTLEBOT3_MODEL=burger`. These must stay in sync across the guide, `Dockerfile`, `compose.yaml` and the Pi's `~/.bashrc`.

## Working rules
- After any meaningful change or milestone (setup step done, bug found/fixed, config changed), add an entry to the top of `logs.md`: date, who, what, and anything left open.
- Keep `setup-guide.md` accurate: if a command turns out to be wrong, fix it there and note it in `logs.md`.
- Commands needing `sudo` can't be run by Claude non-interactively; hand them to the user.
- Don't change `ROS_DOMAIN_ID`, the robot model, or the Jazzy branch pins without updating every place listed above.
