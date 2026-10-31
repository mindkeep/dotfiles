#!/usr/bin/env bash
# Dev machine bootstrap for gng-idle (Flutter) and dippy_ws (ROS 2).
# Targets Ubuntu and Linux Mint. Idempotent: safe to re-run to fill gaps.
# Run as your normal user; sudo is only used by the --apt and --ros steps.
#
# Default (no sudo): gh, Flutter 3.47.1 (CI pin), Temurin JDK 17,
# Android cmdline-tools, all under $HOME.
#
#   --apt    install system packages: desktop build deps, podman/buildah  [sudo]
#   --clone  clone gng-idle and dippy_ws into ~/projects                  [SSH]
#   --ros    run dippy_ws/scripts/setup-dev-machine.sh (ROS 2 Lyrical)   [sudo, resolute only]
#   -h       show this help
set -euo pipefail

FLUTTER_VERSION=3.47.1
JDK_MAJOR=17
SDK=$HOME/sdk
ANDROID_HOME=$HOME/Android/Sdk
BIN=$HOME/.local/bin
PROJECTS=$HOME/projects

DO_APT=0
DO_CLONE=0
DO_ROS=0

say() { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }
die() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

for arg in "$@"; do
  case $arg in
    --apt) DO_APT=1 ;;
    --clone) DO_CLONE=1 ;;
    --ros) DO_ROS=1 ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) die "unknown option: $arg (try --help)" ;;
  esac
done

[[ $EUID -eq 0 ]] && die "run as your normal user, not root"

. /etc/os-release
case ${ID:-} in
  ubuntu|linuxmint) ;;
  *) die "unsupported distro '${ID:-?}': this script targets Ubuntu and Linux Mint" ;;
esac
# Mint sets UBUNTU_CODENAME to its Ubuntu base; dippy_ws keys off that.
UBU_CODENAME=${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}
say "Platform: $PRETTY_NAME (Ubuntu base: $UBU_CODENAME)"

case $(uname -m) in
  x86_64) JDK_ARCH=x64; GH_ARCH=amd64 ;;
  aarch64) JDK_ARCH=aarch64; GH_ARCH=arm64 ;;
  *) die "unsupported architecture: $(uname -m)" ;;
esac

for tool in curl git; do
  have "$tool" || die "$tool is required; install it first (sudo apt install $tool)"
done

install_gh() {
  if [[ -x $BIN/gh ]] || have gh; then say "gh already installed"; return; fi
  say "Installing gh (latest release, checksum verified)"
  local tag ver base name tmp
  tag=$(curl -fsSL https://api.github.com/repos/cli/cli/releases/latest | grep -o '"tag_name": *"[^"]*"' | cut -d'"' -f4)
  ver=${tag#v}
  base=https://github.com/cli/cli/releases/download/$tag
  name=gh_${ver}_linux_${GH_ARCH}.tar.gz
  tmp=$(mktemp -d)
  curl -fsSL -o "$tmp/$name" "$base/$name"
  curl -fsSL -o "$tmp/checksums.txt" "$base/gh_${ver}_checksums.txt"
  (cd "$tmp" && grep " $name\$" checksums.txt | sha256sum -c -)
  tar xzf "$tmp/$name" -C "$tmp"
  install -Dm755 "$tmp/gh_${ver}_linux_${GH_ARCH}/bin/gh" "$BIN/gh"
  mkdir -p "$HOME/.local/share/man/man1"
  cp "$tmp/gh_${ver}_linux_${GH_ARCH}/share/man/man1/"* "$HOME/.local/share/man/man1/"
  rm -rf "$tmp"
}

install_flutter() {
  local dir=$SDK/flutter
  if [[ -x $dir/bin/flutter ]]; then say "Flutter already installed"; return; fi
  say "Cloning Flutter $FLUTTER_VERSION"
  mkdir -p "$SDK"
  git clone -q --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$dir"
  # A tag checkout is detached. Give it the stable branch and upstream so
  # flutter reports the stable channel instead of "user-branch".
  git -C "$dir" checkout -q -B stable
  git -C "$dir" remote set-branches origin stable
  git -C "$dir" fetch -q --depth 1 origin stable
  git -C "$dir" branch -q -u origin/stable
  rm -f "$dir/bin/cache/flutter.version.json"
}

install_jdk() {
  local dir=$SDK/jdk-$JDK_MAJOR tmp
  if [[ -x $dir/bin/java ]]; then say "JDK $JDK_MAJOR already installed"; return; fi
  say "Installing Temurin JDK $JDK_MAJOR"
  tmp=$(mktemp -d)
  # Adoptium's API redirects to the current GA build. No checksum check here.
  curl -fsSL -o "$tmp/jdk.tgz" \
    "https://api.adoptium.net/v3/binary/latest/$JDK_MAJOR/ga/linux/$JDK_ARCH/jdk/hotspot/normal/eclipse"
  mkdir -p "$dir"
  tar xzf "$tmp/jdk.tgz" -C "$dir" --strip-components=1
  rm -rf "$tmp"
}

install_android() {
  local ct=$ANDROID_HOME/cmdline-tools/latest zip tmp
  if [[ -x $ct/bin/sdkmanager ]]; then say "Android cmdline-tools already installed"; return; fi
  say "Installing Android cmdline-tools"
  zip=$(curl -fsSL https://dl.google.com/android/repository/repository2-3.xml \
    | grep -o 'commandlinetools-linux-[0-9]*_latest.zip' | sort -V | tail -1)
  [[ -n $zip ]] || die "could not find cmdline-tools in Google's repository index"
  tmp=$(mktemp -d)
  curl -fsSL -o "$tmp/$zip" "https://dl.google.com/android/repository/$zip"
  python3 -I -m zipfile -e "$tmp/$zip" "$tmp/unpacked"
  mkdir -p "$ANDROID_HOME/cmdline-tools"
  rm -rf "$ct"
  mv "$tmp/unpacked/cmdline-tools" "$ct"
  chmod +x "$ct"/bin/*
  rm -rf "$tmp"
}

install_apt_packages() {
  say "Installing system packages (sudo)"
  sudo -v
  sudo apt-get update -qq
  sudo apt-get install -y curl git ca-certificates python3 \
    clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev ffmpeg \
    podman buildah podman-docker distrobox
}

clone_one() {
  local name=$1
  if [[ -d $PROJECTS/$name/.git ]]; then say "$name already cloned"; return; fi
  say "Cloning $name"
  git clone "git@github.com:mindkeep/$name.git" "$PROJECTS/$name"
}

clone_repos() {
  mkdir -p "$PROJECTS"
  clone_one gng-idle
  clone_one dippy_ws
}

setup_ros() {
  local ws=$PROJECTS/dippy_ws
  [[ -d $ws ]] || die "$ws not found; run with --clone first"
  if [[ $UBU_CODENAME != resolute ]]; then
    warn "dippy_ws targets ROS 2 Lyrical on Ubuntu 26.04 (resolute); this system is '$UBU_CODENAME'. Skipping. For Jazzy, use a noble distrobox (see docs/dev-machine-setup.md)."
    return
  fi
  say "Running dippy_ws ROS 2 setup (sudo)"
  "$ws/scripts/setup-dev-machine.sh"
}

install_gh
install_flutter
install_jdk
install_android
if (( DO_APT )); then install_apt_packages; fi
if (( DO_CLONE )); then clone_repos; fi
if (( DO_ROS )); then setup_ros; fi

say "Done. Manual steps that need you:"
cat <<EOF

  1. Open a new shell so PATH and JAVA_HOME/ANDROID_HOME pick up (src/shrc.common).
  2. gh auth login
  3. sdkmanager --licenses && sdkmanager platform-tools
  4. cd $PROJECTS/gng-idle && flutter doctor && make apk
EOF
