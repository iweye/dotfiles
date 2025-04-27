function reflector-update --description 'Update mirrors'
    sudo reflector --protocol http,https --country Ukraine,Poland,Germany --age 24 --latest 10 --fastest 10 --sort rate --save /etc/pacman.d/mirrorlist
end
