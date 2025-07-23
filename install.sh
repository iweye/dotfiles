#!/bin/bash

clear

if ! ping -c 1 archlinux.org &>/dev/null; then
  clear
  echo "Connect to the internet"
  read -r -s -p "Press Enter to continue..."
  printf "\r\033[K"
  rfkill unblock all
  iwctl
fi

clear
echo "Partition disk:"
echo "  1) /dev/sda1 - efi  >= 1Mb" # 64Mb min if have windows
echo "  2) /dev/sda2 - root >= 10Gb"
echo "  3) /dev/sda3 - home >= 5Gb"
echo "  4) /dev/sda4 - swap >= 2Gb"
read -r -s -p "Press Enter to continue..."
printf "\r\033[K"

cfdisk

mkfs.fat -F32 -n EFI /dev/sda1

root_inodes=1000000 # For partition on 1KK files
mkfs.ext4 -L ROOT -m 1 -i $(( $(blockdev --getsize64 /dev/sda2) / $root_inodes )) /dev/sda2

home_inodes=1000000 # For partition on 1KK files
mkfs.ext4 -L HOME -m 0 -i $(( $(blockdev --getsize64 /dev/sda3) / $home_inodes )) /dev/sda3

mount -o lazytime,noatime,nodiratime /dev/sda2 /mnt
mkdir /mnt/{efi,home}
mount /dev/sda1 /mnt/efi
mount -o lazytime,noatime,nodiratime /dev/sda3 /mnt/home

mkswap /dev/sda4
swapon /dev/sda4 -p 100

sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 25\nILoveCandy/' /etc/pacman.conf
sed -i 's/^SigLevel    = Required DatabaseOptional/SigLevel = Never/' /etc/pacman.conf
clear
echo "Wait for update mirrors..."
reflector --protocol http,https --country Ukraine,Poland,Germany --age 24 --latest 10 --fastest 10 --sort rate --save /etc/pacman.d/mirrorlist &>/dev/null
cp /etc/pacman.d/mirrorlist /mnt/pacman.d/

clear
echo "Wait for install base packages in new system..."
pacstrap /mnt base
genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt sh -c "echo 'root:666' | chpasswd" # Password for root
arch-chroot /mnt useradd -m -G wheel,audio,video,optical,storage user
arch-chroot /mnt sh -c "echo 'user:666' | chpasswd" # Password for user

clear
echo "Wait for the necessary packages to be installed..."
arch-chroot /mnt pacman -Syu --noconfirm
arch-chroot /mnt pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
arch-chroot /mnt pacman-key --lsign-key 3056513887B78AEB
arch-chroot /mnt pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
arch-chroot /mnt pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
arch-chroot /mnt bash -c "echo '[chaotic-aur]' >> /etc/pacman.conf"
arch-chroot /mnt bash -c "echo 'Include = /etc/pacman.d/chaotic-mirrorlist' >> /etc/pacman.conf"
arch-chroot /mnt sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 25\nILoveCandy/' /etc/pacman.conf
arch-chroot /mnt pacman -Syu --noconfirm git rsync paru sudo os-prober grub efibootmgr

clear
echo "Wait for repo's clones..."
arch-chroot /mnt git clone --depth 1 https://github.com/iweye/dotfiles /tmp/dotfiles
clear
echo "Wait for copies configs..."
arch-chroot /mnt rm -rf /etc/systemd/
arch-chroot /mnt rsync -aAX --no-whole-file /tmp/dotfiles/root/ /
# arch-chroot /mnt rsync -aAX --no-whole-file /tmp/dotfiles/home/ /home/user/
arch-chroot /mnt chown -R user:user /home/user

clear
echo "Wait for generates locales..."
arch-chroot /mnt locale-gen

clear
echo "Wait for installs bootloader..."
arch-chroot /mnt mkdir -p /boot/EFI
arch-chroot /mnt mount /dev/sda1 /boot/EFI
arch-chroot /mnt grub-install --bootloader-id=GRUB
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

clear
echo "Wait until all remaining packages are installed..."
arch-chroot /mnt sh -c "sudo -u user paru -Syu --needed --noconfirm - < packages"
