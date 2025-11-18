#!/usr/bin/env bash
set -euo pipefail
echo "[setup] Flutter doctor & packages"
flutter --version
flutter pub get
