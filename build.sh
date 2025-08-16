#!/usr/bin/env bash
sudo pacman -Sy --noconfirm arch-install-scripts xorriso grub mtools systemd-boot dosfstools

ROOTFS=dist/rootfs
ISO=dist/frankos-minimal.iso
EFI=dist/efi
sudo mkdir -p "$ROOTFS" "$EFI"
# クリーン
sudo rm -rf dist
sudo mkdir -p $ROOTFS
# rootfs を pacman で直接構築（pacstrap 非依存）
sudo mkdir -p "$ROOTFS"/var/lib/pacman
sudo pacstrap -c "$ROOTFS" base linux bash vim systemd vim efibootmgr


sudo mkdir -p "$EFI"/EFI/systemd "$EFI"/loader/entries
sudo cp "$ROOTFS"/boot/vmlinuz-linux "$EFI"/vmlinuz-linux
sudo cp "$ROOTFS"/boot/initramfs-linux.img "$EFI"/initramfs-linux.img
sudo mkdir -p dist/efi/loader/entries
sudo tee dist/efi/loader/loader.conf > /dev/null <<EOF
default frankos
timeout 3
EOF

sudo tee dist/efi/loader/entries/frankos.conf > /dev/null <<EOF
title   FrankOS Minimal
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=/dev/sda2 rw quiet
EOF




#sudo pacman -Sy --root "$ROOTFS" --noconfirm base linux bash vim grub efibootmgr

# 1) pacman で rootfs をブートストラップ
# pacstrap -c "$ROOTFS" base linux bash vim

# 2) pacman.conf をコピー（必要に応じてカスタマイズ）
sudo mkdir -p $ROOTFS/etc
sudo cp /etc/pacman.conf $ROOTFS/etc/
sudo dd if=/dev/zero of=dist/frankos-efi.img bs=1M count=64
sudo mkfs.vfat dist/frankos-efi.img
sudo mkdir -p dist/efi/EFI/systemd
sudo cp /usr/lib/systemd/boot/efi/systemd-bootx64.efi dist/efi/EFI/systemd/
sudo mkdir dist/efi/EFI/BOOT
sudo cp /usr/lib/systemd/boot/efi/systemd-bootx64.efi dist/efi/EFI/BOOT/BOOTX64.EFI

sudo mmd -i dist/frankos-efi.img ::/EFI
sudo mcopy -i dist/frankos-efi.img -s dist/efi/* ::/EFI


# 3) ISO 化
sudo xorriso -as mkisofs \
  -iso-level 3 \
  -full-iso9660-filenames \
  -volid "FRANKOS" \
  -output "$ISO" \
  -efi-boot-part --efi-boot-image \
  -isohybrid-gpt-basdat \
  -append_partition 2 0xef dist/frankos-efi.img \
  dist/efi/

