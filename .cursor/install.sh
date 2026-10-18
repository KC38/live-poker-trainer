#!/usr/bin/env bash
# Cloud Agent install step for the Exploitative Poker Lab Flutter app.
#
# Idempotent. Installs the Flutter SDK (pinned) if it is not already present,
# prepares the app's developer-local files, fetches Dart/Flutter packages, and
# installs Cloud Functions dependencies, and installs g++ when Flutter's
# native test assets need C++ headers. With environment builds this runs
# once and is baked into the build snapshot; without builds it runs per agent
# and short-circuits when the toolchain is already in place.
set -euo pipefail

FLUTTER_VERSION="3.47.4"
FLUTTER_HOME="/opt/flutter"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log() { echo "[install] $*"; }

# Prefer sudo for /opt writes; fall back to a home-dir install when sudo is
# unavailable so the step still succeeds on locked-down hosts.
SUDO=""
if command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
  SUDO="sudo"
fi
if [[ -z "$SUDO" && ! -w /opt ]]; then
  FLUTTER_HOME="$HOME/flutter"
fi

# Flutter tests compile and link the soloud native asset with system clang.
# Ubuntu's llvm clang misses Debian's versioned libstdc++ headers and the
# unversioned libstdc++.so (it lives under the gcc lib dir, not the default
# linker path). A link probe fails until a clang config file adds both.
if ! echo 'int main(){return 0;}' | clang -x c++ -lstdc++ -o /tmp/clang-stdcxx-probe - >/dev/null 2>&1; then
  if ! dpkg -s g++ >/dev/null 2>&1; then
    log "installing C++ toolchain for Flutter native assets"
    $SUDO apt-get update
    $SUDO apt-get install -y --no-install-recommends g++
  fi
  cxx_ver="$(find /usr/include/c++ -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort -V | tail -1)"
  gcc_lib="$(dirname "$(g++ -print-file-name=libstdc++.so)")"
  clang_dir="$(dirname "$(readlink -f "$(command -v clang)")")"
  cfg="${clang_dir}/x86_64-pc-linux-gnu-clang.cfg"
  log "pointing clang at libstdc++ ${cxx_ver} via ${cfg}"
  $SUDO tee "$cfg" >/dev/null <<EOF
-I/usr/include/c++/${cxx_ver}
-I/usr/include/x86_64-linux-gnu/c++/${cxx_ver}
-L${gcc_lib}
EOF
  rm -f /tmp/clang-stdcxx-probe
fi

# 1) Install the pinned Flutter SDK if missing.
if [[ ! -x "$FLUTTER_HOME/bin/flutter" ]]; then
  log "installing Flutter ${FLUTTER_VERSION} into ${FLUTTER_HOME}"
  url="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
  tmp="$(mktemp -d)"
  curl -fsSL --retry 4 --retry-delay 4 -o "$tmp/flutter.tar.xz" "$url"
  $SUDO mkdir -p "$(dirname "$FLUTTER_HOME")"
  $SUDO tar xf "$tmp/flutter.tar.xz" -C "$(dirname "$FLUTTER_HOME")"
  $SUDO chown -R "$(id -u):$(id -g)" "$FLUTTER_HOME" || true
  rm -rf "$tmp"
else
  log "Flutter already present at ${FLUTTER_HOME}"
fi

export PATH="$FLUTTER_HOME/bin:$PATH"

# Make flutter/dart resolvable in fresh shells (symlink when we can, otherwise
# ensure PATH via ~/.bashrc without duplicating the entry).
if [[ -n "$SUDO" ]]; then
  $SUDO ln -sf "$FLUTTER_HOME/bin/flutter" /usr/local/bin/flutter
  $SUDO ln -sf "$FLUTTER_HOME/bin/dart" /usr/local/bin/dart
elif ! grep -q "$FLUTTER_HOME/bin" "$HOME/.bashrc" 2>/dev/null; then
  echo "export PATH=\"$FLUTTER_HOME/bin:\$PATH\"" >> "$HOME/.bashrc"
fi

# git safe.directory so Flutter's version probe and the checkout both work.
git config --global --add safe.directory "$FLUTTER_HOME" 2>/dev/null || true
git config --global --add safe.directory "$REPO_ROOT" 2>/dev/null || true

flutter config --no-analytics >/dev/null 2>&1 || true
flutter config --enable-web >/dev/null 2>&1 || true

# 2) Generate the gitignored developer-local files (.env, firebase_options.dart).
bash "$REPO_ROOT/.cursor/bootstrap.sh"

# 3) Fetch packages and warm the web engine cache.
cd "$REPO_ROOT"
flutter pub get
flutter precache --web >/dev/null 2>&1 || true

# 4) Cloud Functions toolchain (Node 22 is on the base image). npm ci is
#    lockfile-exact and safe to repeat.
if [[ -f "$REPO_ROOT/functions/package-lock.json" ]]; then
  log "installing Cloud Functions dependencies"
  (cd "$REPO_ROOT/functions" && npm ci)
fi

log "flutter: $(flutter --version | head -1)"
log "done"
