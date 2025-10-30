#!/usr/bin/env bash
set -euo pipefail
echo "[test] Static analysis"
flutter analyze
echo "[test] Unit tests"
flutter test --reporter expanded
