#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VARIANT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT_DIR="$(cd "$VARIANT_DIR/.." && pwd)"

if [ ! -f "$ROOT_DIR/.env" ]; then
    echo "❌ ERRO: Arquivo $ROOT_DIR/.env não encontrado."
    exit 1
fi

if [ ! -f "$VARIANT_DIR/.env" ]; then
    echo "❌ ERRO: Arquivo $VARIANT_DIR/.env não encontrado."
    exit 1
fi

set -a
. "$ROOT_DIR/.env"
. "$VARIANT_DIR/.env"
set +a

echo "==> Building $IMAGE:$TAG..."
docker build --platform=linux/amd64 -t "$IMAGE:$TAG" "$VARIANT_DIR"

echo "==> Running automated tests for $IMAGE:$TAG before pushing..."
if ! "$ROOT_DIR/tests/test-images.sh" "php$TAG" "$IMAGE:$TAG"; then
    echo "❌ ERRO: Os testes falharam para a imagem $IMAGE:$TAG! O envio para o Docker Hub foi cancelado."
    exit 1
fi

echo "✅ Testes aprovados! Enviando $REPOSITORY/$IMAGE:$TAG para o Docker Hub..."
docker tag "$IMAGE:$TAG" "$REPOSITORY/$IMAGE:$TAG"
docker tag "$IMAGE:$TAG" "$REPOSITORY/$IMAGE:latest"
docker push "$REPOSITORY/$IMAGE:$TAG"
#docker push "$REPOSITORY/$IMAGE:latest"
