function update --description 'Update mirrors and packages'
  sudo reflector --protocol http,https --country Ukraine,Poland,Germany --age 24 --latest 10 --fastest 10 --sort rate --save /etc/pacman.d/mirrorlist
  sudo pacman -Syu --needed --noconfirm
end
