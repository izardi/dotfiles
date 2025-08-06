
# config source

sudo echo "[archlinuxcn]

Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/\$arch" >> etc/pacman.conf

# install yay
sudo pacman -Syu --noconfirm
sudo pacman -S archlinuxcn-keyring --noconfirm
sudo pacman -S yay --noconfirm


# install software

yay -S strace lapce npm telegram-desktop python-pip python-pynvim fcitx5-configtool qt5-wayland qt6-wayland fcitx5-gtk fcitx5-qt fcitx5 fcitx5-chinese-addons neofetch imv zathura zathura-pdf-mupdf mpv dunst rust gcc clang cmake mariadb python nodejs ttf ttf-firacode-nerd ttf-liberation ttf-fira-code ttf-maple-sc-nerd ttf-jetbrains-mono ttf-nerd-fonts-symbols ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols-common code qtcreator alacritty wayland sway gdb firefox fuzzel --noconfirm



# config git
#
git config --global user.name "zard"
git config --global user.email "yuhh.cs@gmail.com"


