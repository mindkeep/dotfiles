# Dev machine setup: gng-idle + dippy_ws (Ubuntu 26.04)

Already installed user-local (no sudo):

| Tool | Location |
| --- | --- |
| gh 2.103.3 | `~/.local/bin/gh` |
| Flutter 3.47.1 stable (CI pin) | `~/sdk/flutter` |
| Temurin JDK 17 | `~/sdk/jdk-17` (`JAVA_HOME`) |
| Android cmdline-tools | `~/Android/Sdk` (`ANDROID_HOME`) |

PATH and env are set in `src/shrc.common`. Open a new shell to pick them up.

## 1. Things that need you (sudo / licenses)

```bash
gh auth login
```

Accept the Android SDK licenses and install platform-tools. Gradle fetches
the platform, build-tools and NDK itself on the first `make apk`:

```bash
sdkmanager --licenses && sdkmanager "platform-tools"
```

Linux desktop target + `tool/record.sh`:

```bash
sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev ffmpeg
```

Check everything:

```bash
flutter doctor
cd ~/projects/gng-idle && make apk
```

(Chrome is only needed for `flutter run -d chrome`; set `CHROME_EXECUTABLE`
if you use Chromium.)

## 2. ROS 2 for dippy_ws (`~/projects/dippy_ws`)

The workspace targets **ROS 2 Lyrical** on 26.04 (Jazzy has no `resolute`
packages). Its bootstrap script adds the ROS apt repo, installs
`ros-dev-tools` (colcon, rosdep, vcstool, compilers), `ros-lyrical-desktop`,
ros2_control/controllers, xacro, and the Gazebo bridge packages, then runs
`rosdep init/update`. It's idempotent and calls sudo itself:

```bash
cd ~/projects/dippy_ws && ./scripts/setup-dev-machine.sh
```

Then build and test:

```bash
source /opt/ros/lyrical/setup.bash
cd ~/projects/dippy_ws
rosdep install --from-paths src --ignore-src -r -y
colcon build --symlink-install
source install/setup.bash
colcon test --packages-select dippy_control && colcon test-result --verbose
```

## 3. Containers: podman/buildah

For this workload podman works as well as Docker. Install:

```bash
sudo apt install podman buildah podman-docker distrobox
```

- `podman-docker` provides a `docker` command, so scripts that call
  `docker run`/`docker build` keep working.
- **distrobox** is the easiest way to get a ROS 2 Jazzy (noble) box if you
  need Jazzy specifically. It shares `$HOME`, X11/Wayland and the GPU, so
  RViz and Gazebo work without extra setup:
  `distrobox create -n jazzy -i docker.io/osrf/ros:jazzy-desktop && distrobox enter jazzy`
- Plain `podman run`: add `--network=host` (DDS discovery multicast) and
  `--ipc=host` (Fast DDS shared memory). For GUI add `--device /dev/dri`
  plus the X/Wayland socket mounts. For serial or USB hardware use
  `--device /dev/ttyACM0` and `--group-add keep-groups`.
- Where proper Docker still helps: devcontainer or compose tooling that
  expects the Docker socket (`systemctl --user enable --now podman.socket`
  usually fixes it), and GPU passthrough with the NVIDIA runtime, which needs
  CDI (`nvidia-ctk cdi generate`) on podman. Otherwise podman is fine.
