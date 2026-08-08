#!/usr/bin/env bash
set -euo pipefail

VERSION="0.10.1"
SHA256="374ea58d30c79ff470b6fea2ba08244922cab6cba4bf5fd6d818911b5fd38021"
DMG_URL="https://github.com/Hunter9568/Strazh-Releases/releases/download/v${VERSION}/Strazh-${VERSION}-arm64.dmg"
TEMP_DIR="$(mktemp -d /tmp/strazh-install.XXXXXX)"
DMG="$TEMP_DIR/Strazh.dmg"
MOUNT="$TEMP_DIR/mount"
TARGET="${STRAZH_INSTALL_TARGET:-/Applications/Страж.app}"
DESKTOP_DIR="${STRAZH_DESKTOP_DIR:-$HOME/Desktop}"
DESKTOP_LINK="$DESKTOP_DIR/Страж.app"

cleanup() {
  hdiutil detach "$MOUNT" >/dev/null 2>&1 || true
  [[ "$TEMP_DIR" == /tmp/strazh-install.* ]] && rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo "Скачиваю «Страж» ${VERSION}…"
if [[ -n "${STRAZH_DMG_PATH:-}" ]]; then
  cp "$STRAZH_DMG_PATH" "$DMG"
else
  curl -fL --progress-bar "$DMG_URL" -o "$DMG"
fi
echo "$SHA256  $DMG" | shasum -a 256 -c -

mkdir -p "$MOUNT"
hdiutil attach "$DMG" -nobrowse -readonly -mountpoint "$MOUNT" >/dev/null

echo "Устанавливаю в ${TARGET}…"
if [[ "$TARGET" == "/Applications/Страж.app" ]]; then
  sudo ditto "$MOUNT/Страж.app" "$TARGET"
else
  mkdir -p "$(dirname "$TARGET")"
  ditto "$MOUNT/Страж.app" "$TARGET"
fi

mkdir -p "$DESKTOP_DIR"
if [[ ! -e "$DESKTOP_LINK" && ! -L "$DESKTOP_LINK" ]]; then
  ln -s "$TARGET" "$DESKTOP_LINK"
  echo "Ярлык создан на рабочем столе."
else
  echo "Объект «Страж.app» уже существует на рабочем столе — оставляю его без изменений."
fi

echo "Установка завершена. Открываю «Страж»…"
if [[ "${STRAZH_NO_LAUNCH:-0}" != "1" ]]; then
  open "$TARGET"
fi
