#!/bin/sh
set -e

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
TAG="${1:-8.5}"

# Normalize folder name (e.g. "8.5" -> "php8.5", "php8.5" -> "php8.5")
case "$TAG" in
    php*) VARIANT="$TAG"; CLEAN_TAG="${TAG#php}" ;;
    *)    VARIANT="php$TAG"; CLEAN_TAG="$TAG" ;;
esac

VARIANT_DIR="$ROOT_DIR/$VARIANT"

if [ ! -d "$VARIANT_DIR" ]; then
    echo "❌ ERRO: Diretório da versão '$VARIANT' não encontrado em $ROOT_DIR"
    exit 1
fi

if [ -f "$VARIANT_DIR/scripts/build.sh" ]; then
    sh "$VARIANT_DIR/scripts/build.sh"
else
    echo "❌ ERRO: Script $VARIANT_DIR/scripts/build.sh não encontrado."
    exit 1
fi
