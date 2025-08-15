#!/usr/bin/env bash
set -euo pipefail

ROOTFS=dist/rootfs
ISO=dist/frankos-minimal.iso

# クリーン
rm -rf dist
mkdir -p $ROOTFS
pacstrap -c -d dist/rootfs base linux
# 1) pacman で rootfs をブートストラップ
pacman -Sy --noconfirm \
  --root="$ROOTFS" \
  --dbpath="$ROOTFS/var/lib/pacman" \
  base linux bash vim

# 2) pacman.conf をコピー（必要に応じてカスタマイズ）
mkdir -p $ROOTFS/etc
cp /etc/pacman.conf $ROOTFS/etc/

# 3) ISO 化
xorriso -as mkisofs \
  -o "$ISO" \
  -J -R \
  "$ROOTFS"
