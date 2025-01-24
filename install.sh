#!/bin/bash

if [[ "$(uname -n)" == "archinstall" ]]; then
  echo "Running in installer environment."

  if ! ping -c 1 archlinux.org &>/dev/null; then
    echo "No internet connection detected."

    read -p "Do you want help connecting to the internet? (yes/no): " connect_help
    connect_help=${connect_help:-yes}

    if [[ "$connect_help" == "yes" ]]; then
      echo "Unblocking wireless interfaces..."
      rfkill unblock all

      echo "Starting iwctl for Wi-Fi setup. Follow these steps:"
      echo "1. Type 'device list' to identify your wireless device."
      echo "2. Type 'station <device_name> scan' to scan for networks."
      echo "3. Type 'station <device_name> connect <SSID>' to connect to your network."
      echo "4. Type 'exit' to return to the script after connecting."
      echo
      iwctl

      if ! ping -c 1 archlinux.org &>/dev/null; then
        echo "Error: Still no internet connection. Please check your setup."
        exit 1
      fi
    else
      echo "Internet is required to continue. Please connect manually and restart the script."
      exit 1
    fi

    echo "Internet connection established. Proceeding with the script..."
  else
    echo "Internet connection detected. Proceeding with the script..."
  fi

  read -p "Have you already partitioned your disk? (yes/no): " disk_partitioned

  if [[ "$disk_partitioned" != "yes" ]]; then
    echo "You need:"
    echo "- A UEFI partition (128M, formatted as FAT32)"
    echo "- A root partition for the system."
    read -p "Do you want to partition your disk using cfdisk now? (yes/no): " use_cfdisk

    if [[ "$use_cfdisk" == "yes" ]]; then
      echo "Launching cfdisk..."
      cfdisk
      echo "Partitioning completed. Proceeding with the script..."
    else
      echo "Error: Disk must be partitioned before running this script."
      exit 1
    fi
  fi

  echo "Disk partitioning confirmed. Proceeding with the script..."

  echo "Available partitions:"
  lsblk -o NAME,SIZE,TYPE,MOUNTPOINT

  read -p "Enter the EFI partition (default: /dev/sda1): " efi_partition
  efi_partition=${efi_partition:-/dev/sda1}
  echo "EFI partition: $efi_partition"

  read -p "Enter the root partition (default: /dev/sda2): " root_partition
  root_partition=${root_partition:-/dev/sda2}
  echo "Root partition: $root_partition"

  echo "Partitions confirmed. Proceeding with the script..."

  read -p "Do you want to format the EFI partition ($efi_partition)? (yes/no): " format_efi

  if [[ "$format_efi" == "yes" ]]; then
    echo "Formatting EFI partition ($efi_partition) as FAT32..."
    mkfs.fat -F32 "$efi_partition"
    echo "EFI partition formatted successfully."
  else
    echo "Skipping EFI partition formatting."
  fi

  read -p "Do you want to format the root partition ($root_partition)? (yes/no): " format_root

  if [[ "$format_root" == "yes" ]]; then
    echo "Formatting root partition ($root_partition) as XFS..."
    mkfs.xfs "$root_partition"
    echo "Root partition formatted successfully."
  else
    echo "Skipping root partition formatting."
  fi

  echo "Mounting root partition ($root_partition) to /mnt..."
  mount "$root_partition" /mnt
  echo "Root partition mounted successfully."

  echo "Creating /mnt/boot/efi directory..."
  mkdir -p /mnt/efi
  echo "Mounting EFI partition ($efi_partition) to /mnt/boot/efi..."
  mount "$efi_partition" /mnt/efi
  echo "EFI partition mounted successfully."

  mirrorlist="Server = https://mirror.lcarilla.de/archlinux/\$repo/os/\$arch
  Server = https://mirror.moson.org/arch/\$repo/os/\$arch
  Server = https://archlinux.thaller.ws/\$repo/os/\$arch
  Server = https://mirror.hugo-betrugo.de/archlinux/\$repo/os/\$arch
  Server = https://de.arch.niranjan.co/\$repo/os/\$arch
  Server = https://arch.phinau.de/\$repo/os/\$arch
  Server = https://mirror.juniorjpdj.pl/archlinux/\$repo/os/\$arch
  Server = https://europe.mirror.pkgbuild.com/\$repo/os/\$arch
  Server = https://md.mirrors.hacktegic.com/archlinux/\$repo/os/\$arch
  Server = https://mirror.telepoint.bg/archlinux/\$repo/os/\$arch"

  echo "Choose an option for the mirrorlist:"
  echo "1. Use predefined mirrorlist (faster)"
  echo "2. Update mirrorlist with Reflector (slower)"
  read -p "Enter your choice (1/2): " mirror_choice
  mirror_choice=${mirror_choice:-1}

  if [[ "$mirror_choice" == "2" ]]; then
    echo "Updating mirrorlist with Reflector. This may take some time..."
    reflector --protocol https \
      --country Ukraine,Poland,Germany,Czechia,Romania,Slovakia,Moldova,Bulgaria,Hungary,Serbia \
      --age 24 --latest 10 --fastest 10 --sort rate > /tmp/mirrorlist

    if [[ $? -eq 0 ]]; then
      echo "Mirrorlist updated successfully with Reflector."
      mirrorlist=$(cat /tmp/mirrorlist)
    else
      echo "Error: Failed to update mirrorlist with Reflector. Using the predefined list instead."
    fi
  fi

  echo "Writing selected mirrorlist to /etc/pacman.d/mirrorlist..."
  echo "$mirrorlist" > /etc/pacman.d/mirrorlist
  echo "Mirrorlist has been updated."

  echo "Configuring pacman for faster downloads..."
  echo -e "\nParallelDownloads = 25\nILoveCandy" >> /etc/pacman.conf
  echo "Pacman configuration updated successfully."

  echo "Updating pacman database..."
  pacman -Sy
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to update pacman database. Please check your internet connection and mirrorlist."
    exit 1
  fi
  echo "Pacman database updated successfully."

  echo "Installing the base system with pacstrap..."
  pacstrap /mnt base linux linux-firmware xfsprogs iwctl grub efibootmgr os-prober gdm sudo neovim
  echo "Base system installed successfully."

  echo "Generating fstab..."
  genfstab -U /mnt >> /mnt/etc/fstab
  echo "fstab generated successfully."

  echo "Copying the installation script to the new system..."
  cp "$0" /mnt/tmp/setup-chroot.sh

  echo "Making the script executable..."
  chmod +x /mnt/tmp/setup-chroot.sh

  echo "Entering chroot environment and continuing the setup..."
  arch-chroot /mnt /bin/bash -c "/tmp/setup-chroot.sh"

else
  echo "Running inside chroot."

  echo "Choose an option for the mirrorlist:"
  echo "1. Use predefined mirrorlist (faster)"
  echo "2. Update mirrorlist with Reflector (slower)"
  read -p "Enter your choice (1/2): " mirror_choice
  mirror_choice=${mirror_choice:-1}

  if [[ "$mirror_choice" == "2" ]]; then
    echo "Updating mirrorlist with Reflector. This may take some time..."
    reflector --protocol https \
      --country Ukraine,Poland,Germany,Czechia,Romania,Slovakia,Moldova,Bulgaria,Hungary,Serbia \
      --age 24 --latest 10 --fastest 10 --sort rate > /tmp/mirrorlist

    if [[ $? -eq 0 ]]; then
      echo "Mirrorlist updated successfully with Reflector."
      mirrorlist=$(cat /tmp/mirrorlist)
    else
      echo "Error: Failed to update mirrorlist with Reflector. Using the predefined list instead."
    fi
  fi

  echo "Configuring pacman for faster downloads..."
  echo -e "\nParallelDownloads = 25\nILoveCandy" >> /etc/pacman.conf
  echo "Pacman configuration updated successfully."

  echo "Updating pacman database..."
  pacman -Sy
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to update pacman database. Please check your internet connection and mirrorlist."
    exit 1
  fi
  echo "Pacman database updated successfully."

  echo "Importing Chaotic AUR key..."
  pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
  pacman-key --lsign-key 3056513887B78AEB
  echo "Chaotic AUR key imported successfully."

  echo "Installing chaotic-keyring and chaotic-mirrorlist..."
  pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
  pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
  echo "Chaotic AUR packages installed successfully."

  echo "Adding Chaotic AUR repository to pacman.conf..."
  echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf
  echo "Chaotic AUR repository added to pacman.conf."

  echo "Syncing mirrorlist and updating the system..."
  pacman -Syu
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to update the system."
    exit 1
  fi
  echo "System updated successfully."

  echo "Configuring time and timezone..."

  timedatectl set-ntp true
  echo "NTP synchronization enabled."

  timedatectl set-timezone Europe/Kiev
  echo "Timezone set to Europe/Kiev."

  ln -sf /usr/share/zoneinfo/Europe/Kiev /etc/localtime
  echo "Timezone symbolic link created."

  hwclock --systohc
  echo "Hardware clock synchronized with system time."

  echo "Time and timezone configuration completed."

  echo "Configuring hostname and user setup..."

  read -p "Enter hostname (default: iweye-pc): " hostname
  hostname=${hostname:-iweye-pc}
  echo "$hostname" > /etc/hostname
  echo "127.0.0.1   localhost" > /etc/hosts
  echo "::1         localhost" >> /etc/hosts
  echo "127.0.1.1   $hostname.localdomain $hostname" >> /etc/hosts
  echo "Hostname configured as $hostname."

  echo "Set root password:"
  passwd

  read -p "Enter username (default: iweye): " username
  username=${username:-iweye}

  useradd -m -G wheel -s /bin/bash "$username"
  echo "User $username created."

  echo "Set password for user $username:"
  passwd "$username"

  usermod -aG audio,video,storage,optical "$username"
  echo "User $username added to groups: audio, video, storage, optical."

  echo "Enabling sudo for the wheel group..."
  sed -i '/%wheel ALL=(ALL:ALL) ALL/s/^# //' /etc/sudoers
  echo "Sudo enabled for the wheel group."

  echo "Hostname and user setup completed."

  read -p "Do you want to enable Bluetooth support? (yes/no): " enable_bluetooth
  enable_bluetooth=${enable_bluetooth:-yes}

  if [[ "$enable_bluetooth" == "yes" ]]; then
    echo "Installing Bluetooth packages..."
    pacman -S --noconfirm bluez bluez-utils

    echo "Enabling the Bluetooth service..."
    systemctl enable bluetooth

    echo "Checking if the 'bluetooth' group exists..."
    if getent group bluetooth > /dev/null; then
      echo "Adding user $username to the 'bluetooth' group..."
      usermod -aG bluetooth "$username"
    else
      echo "Error: 'bluetooth' group does not exist. Something went wrong with the installation."
    fi

    echo "Bluetooth setup completed successfully."
  else
    echo "Skipping Bluetooth setup."
  fi

  echo "Cloning your dotfiles repository..."
  repo_url="https://github.com/iweye/dotfiles"
  tmp_repo_dir="/tmp/dotfiles"

  if git clone "$repo_url" "$tmp_repo_dir"; then
    echo "Repository cloned successfully."
  else
    echo "Error: Failed to clone the repository. Please check the URL or your internet connection."
    exit 1
  fi

  if [[ -d "$tmp_repo_dir/root" ]]; then
    echo "Syncing root files from the repository to the system..."
    rsync -a --info=progress2 "$tmp_repo_dir/root/" /
    echo "Root files synced successfully."
  else
    echo "Warning: 'root' folder not found in the repository. Skipping root sync."
  fi

  if [[ -d "$tmp_repo_dir/home" ]]; then
    echo "Syncing home files from the repository to /home/$username..."
    rsync -a --info=progress2 "$tmp_repo_dir/home/" "/home/$username/"
    echo "Home files synced successfully."
  else
    echo "Warning: 'home' folder not found in the repository. Skipping home sync."
  fi

  echo "Setting ownership of home directory for user $username..."
  chown -R "$username:$username" "/home/$username"
  echo "Ownership updated successfully."

  echo "Installing paru from Chaotic AUR..."
  sudo pacman -S --noconfirm paru
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to install paru. Exiting."
    exit 1
  fi
  echo "Paru installed successfully."

  packages_file="$tmp_repo_dir/packages"
  if [[ -f "$packages_file" ]]; then
    echo "Installing packages listed in the $packages_file..."
    sudo -u "$username" paru -S --noconfirm --needed - < "$packages_file"
    if [[ $? -eq 0 ]]; then
      echo "All packages installed successfully."
    else
      echo "Error: Failed to install some packages. Please check the output for details."
    fi
  else
    echo "Warning: packages file not found in the repository. Skipping package installation."
  fi

  echo "Installing GRUB bootloader..."

  pacman -S --noconfirm grub efibootmgr os-prober
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to install GRUB or required packages. Exiting."
    exit 1
  fi
  echo "GRUB and necessary packages installed successfully."

  echo "Installing GRUB on the EFI partition..."
  grub-install --target=x86_64-efi --bootloader-id=GRUB --recheck --no-floppy
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to install GRUB. Exiting."
    exit 1
  fi
  echo "GRUB installed successfully."

  echo "Generating GRUB configuration file..."
  grub-mkconfig -o /boot/grub/grub.cfg
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to generate GRUB configuration. Exiting."
    exit 1
  fi
  echo "GRUB configuration file generated successfully."

  echo "Updating initramfs..."
  mkinitcpio -P
  echo "initramfs updated successfully."

  echo "Checking total RAM..."

  total_ram=$(free -m | awk '/^Mem:/{print $2}')

  default_swap_size=$((total_ram / 2))

  echo "Total RAM: $total_ram MB"
  echo "Suggested swap size: $default_swap_size MB"

  read -p "Enter swap size (in MB or GB, default: ${default_swap_size}MB): " swap_size
  swap_size=${swap_size:-$default_swap_size}

  if [[ "$swap_size" =~ [Gg]$ ]]; then
    swap_size_mb=$((swap_size * 1024))
  elif [[ "$swap_size" =~ [Mm]$ ]]; then
    swap_size_mb=$swap_size
  else
    swap_size_mb=$swap_size
  fi

  echo "Creating swap file with size $swap_size_mb MB..."

  fallocate -l "${swap_size_mb}M" /swapfile
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to create swap file. Exiting."
    exit 1
  fi

  mkswap /swapfile
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to format swap file. Exiting."
    exit 1
  fi

  swapon /swapfile
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to enable swap. Exiting."
    exit 1
  fi

  echo "/swapfile none swap defaults 0 0" >> /etc/fstab
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to update /etc/fstab. Exiting."
    exit 1
  fi

  echo "Swap file created and enabled successfully."

  echo "Installing gdm..."
  sudo paru -S --noconfirm --needed gdm

  echo "Enabling and starting gdm..."
  sudo systemctl enable gdm.service

  echo "gdm should now be installed and running."

  read -p "Do you want to enable autologin for the user $username? (y/n) [default: y]: " autologin_choice

  if [[ -z "$autologin_choice" || "$autologin_choice" == "y" || "$autologin_choice" == "Y" ]]; then
    echo "Enabling autologin for $username..."
    sudo sed -i "s/^AutomaticLoginEnable=False/AutomaticLoginEnable=True/" /etc/gdm/custom.conf
    sudo sed -i "s/^#AutomaticLogin=dgod/AutomaticLogin=$username/" /etc/gdm/custom.conf
    echo "Autologin enabled for $username."
  else
    echo "Autologin has been disabled."
  fi
fi
