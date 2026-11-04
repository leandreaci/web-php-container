#!/bin/sh
set -e

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODE="${1:-}"

if [ "$MODE" = "--test-only" ] || [ "$MODE" = "--no-push" ]; then
    echo "==> Building and testing all PHP versions locally (updating readme.md badges without pushing to Docker Hub)..."
    exec "$ROOT_DIR/tests/test-images.sh" all
else
    exec "$ROOT_DIR/build.sh" all
fi
