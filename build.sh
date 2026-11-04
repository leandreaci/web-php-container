#!/bin/sh
set -e

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
TAG="${1:-8.5}"

ALL_VARIANTS="7.3 7.4 8.0 8.1 8.2 8.3 8.4 8.5"

build_single() {
    TARGET_TAG="$1"
    case "$TARGET_TAG" in
        php*) VARIANT="$TARGET_TAG"; CLEAN_TAG="${TARGET_TAG#php}" ;;
        *)    VARIANT="php$TARGET_TAG"; CLEAN_TAG="$TARGET_TAG" ;;
    esac

    VARIANT_DIR="$ROOT_DIR/$VARIANT"

    if [ ! -d "$VARIANT_DIR" ]; then
        echo "❌ ERRO: Diretório da versão '$VARIANT' não encontrado em $ROOT_DIR"
        return 1
    fi

    if [ -f "$VARIANT_DIR/scripts/build.sh" ]; then
        sh "$VARIANT_DIR/scripts/build.sh"
    else
        echo "❌ ERRO: Script $VARIANT_DIR/scripts/build.sh não encontrado."
        return 1
    fi
}

case "$TAG" in
    all)
        echo "==> Building, testing, and publishing ALL PHP versions: $ALL_VARIANTS"
        for v in $ALL_VARIANTS; do
            echo ""
            echo "========================================================"
            echo "🚀 Processing version: php$v"
            echo "========================================================"
            build_single "$v"
        done
        echo ""
        echo "✅ Todas as versões ($ALL_VARIANTS) foram buildadas, testadas, atualizadas no readme.md e publicadas com sucesso!"
        ;;
    *)
        build_single "$TAG"
        ;;
esac
