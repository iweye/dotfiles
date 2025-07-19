function pacman-update --description 'Update packages'
  sudo pacman -Syu --needed --noconfirm
end
