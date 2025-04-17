#!/bin/bash

internet() {
  if ! ping -c 1 archlinux.org &>/dev/null; then
    rfkill unblock all
    iwctl
  fi
}

disk(){
  cfdisk

  read -p "EFI partition (default: /dev/sda1): " efi
  efi="${efi:-/dev/sda1}"
  read -p "Format it? (default: no) (y/n): " efi_format
  efi_format="${efi_format:-n}"

  if [[ "$efi_format" == "y" || "$efi_format" == "Y" ]]; then
    mkfs.fat -F32 -n EFI "$efi"
  fi

  read -p "Root partition (default: /dev/sda2): " root
  root="${root:-/dev/sda2}"
  read -p "Format it? (default: no) (y/n): " root_format
  root_format="${root_format:-n}"

  if [[ "$root_format" == "y" || "$root_format" == "Y" ]]; then
    mkfs.ext4 -L root -m 1 -T default "$root"
  fi

  read -p "Home partition (default: /dev/sda3): " home
  home="${home:-/dev/sda3}"
  read -p "Format it? (default: no) (y/n): " home_format
  home_format="${home_format:-n}"

  if [[ "$home_format" == "y" || "$home_format" == "Y" ]]; then
    mkfs.ext4 -L home -m 0 -T largefile "$home"
  fi

  mount "$root" /mnt
  mkdir /mnt/{efi,home}
  mount "$efi" /mnt/efi
  mount "$home" /mnt/home
}

swap() {
  echo "Choose swap method:"
  echo "1) Partition"
  echo "2) File"
  echo "3) No swap"
  read -p "Your choice [1/2/3] (default: 1): " swap_choice
  swap_choice="${swap_choice:-1}"

  case "$swap_choice" in
    1)
      read -p "Swap partition (default: /dev/sda4): " swap_part
      swap_part="${swap_part:-/dev/sda4}"
      mkswap "$swap_part"
      swapon "$swap_part"
      ;;
    2)
      fallocate -l 2G /mnt/swapfile
      chmod 600 /mnt/swapfile
      mkswap /mnt/swapfile
      swapon /mnt/swapfile
      ;;
    3)
      echo "No swap will be created."
      ;;
    *)
      echo "Invalid option. No swap will be created."
      ;;
  esac
}

internet
disk
swap

pacstrap /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab

# Enter chroot
arch-chroot /mnt <<EOF
pacman -Syu

pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
pacman-key --lsign-key 3056513887B78AEB
pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
echo "[chaotic-aur]" >> /etc/pacman.conf
echo "Include = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf
sudo sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 25\nILoveCandy/' /etc/pacman.conf
pacman -Syu git reflector paru sudo os-prober grub efibootmgr

useradd -m -G wheel,audio,video,optical,storage -s /bin/sh iweye
passwd iweye

cd /tmp/
git clone --depth 1 https://github.com/iweye/dotfiles
cd dotfiles/
rsync -aAX --no-whole-file root/ /
rsync -aAX --no-whole-file home/ /home/iweye/
chown -R iweye:iweye /home/iweye

locale-gen
timedatectl set-ntp true
hwclock --systohc

mkdir /boot/EFI
efi=$(findmnt -n -o SOURCE /efi | grep '^/dev/' | head -n1)
mount "$efi" /boot/EFI
grub-install --bootloader-id=GRUB

reflector --protocol https --country Ukraine,Poland,Germany --age 24 --latest 10 --fastest 10 --sort rate --save /etc/pacman.d/mirrorlist
sudo -u iweye paru -S --needed --noconfirm - < packages
EOF
