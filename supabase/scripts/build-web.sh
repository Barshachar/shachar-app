#!/usr/bin/env bash
set -euo pipefail

cd ../app
flutter build web --release
