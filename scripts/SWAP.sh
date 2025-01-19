#!/bin/bash

# Функція для перевірки наявності sudo
check_sudo() {
    if command -v sudo &>/dev/null; then
        SUDO="sudo"
    else
        SUDO=""
    fi
}

# Отримання розміру оперативної пам'яті
get_ram_size() {
    free -m | awk '/^Mem:/ {print $2}'
}

# Функція для перевірки коректності введення числа
is_number() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

# Перевіряємо наявність sudo
check_sudo

# Отримуємо розмір оперативної пам'яті
ram_size=$(get_ram_size)
recommended_swap=$(($ram_size / 2))

# Запитуємо розмір SWAP у користувача
echo "Рекомендований розмір SWAP: ${recommended_swap}M"
read -p "Введіть розмір SWAP (наприклад, 1024M або 2G) [за замовчуванням ${recommended_swap}M]: " swap_size
swap_size=${swap_size:-${recommended_swap}M}

# Перевіряємо формат введення
if [[ ! $swap_size =~ ^[0-9]+[MG]$ ]]; then
    echo "Неправильний формат. Введіть число з 'M' (Мб) або 'G' (Гб) в кінці."
    exit 1
fi

# Пропонуємо шлях до SWAP-файлу
default_swap_file="/swapfile"
echo "Шлях до SWAP-файлу за замовчуванням: $default_swap_file"
read -p "Введіть шлях до SWAP-файлу [за замовчуванням $default_swap_file]: " swap_file
swap_file=${swap_file:-$default_swap_file}

# Створення SWAP-файлу
echo "Створюється SWAP-файл $swap_file розміром $swap_size..."
$SUDO fallocate -l "$swap_size" "$swap_file" || {
    echo "Помилка створення SWAP-файлу."
    exit 1
}

# Встановлення дозволів
$SUDO chmod 600 "$swap_file"

# Форматування у SWAP
$SUDO mkswap "$swap_file"

# Активація SWAP
$SUDO swapon "$swap_file"

# Додавання до fstab
$SUDO sh -c echo "$swap_file none swap sw 0 0" >> /etc/fstab

echo "SWAP успішно створено та активовано."
