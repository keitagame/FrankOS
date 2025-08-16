#!/usr/bin/env bash
set -euo pipefail

ROOTFS=dist/rootfs
ISO=dist/frankos-minimal.iso

# クリーン
rm -rf dist
mkdir -p $ROOTFS

# 1) pacman で rootfs をブートストラップ
pacstrap -c -root "$ROOTFS" base linux bash vim

# 2) pacman.conf をコピー（必要に応じてカスタマイズ）
mkdir -p $ROOTFS/etc
cp /etc/pacman.conf $ROOTFS/etc/

# 3) ISO 化
xorriso -as mkisofs \
  -o "$ISO" \
  -J -R \
  "$ROOTFS"
