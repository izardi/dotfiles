timedatectl set-timezone Asia/Shanghai
timedatectl set-ntp true


mount /dev/nvme0n1p4 /mnt
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot

echo "Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist

pacstrap /mnt base base-devel linux-lts linux-firmware linux-lts-headers fish networkmanager dhcpcd openssh neovim git os-prober efibootmgr ntfs-3g intel-ucode man-db man-pages noto-fonts-cjk noto-fonts-emoji 

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt

ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
ln -s /bin/nvim /bin/vi
ln -s /bin/nvim /bin/vim

hwclock --systohc

nvim /etc/locale.gen

locale-gen

echo 'LANG=en_US.UTF-8'  > /etc/locale.conf

touch /etc/hostname
echo "yu" > /etc/hostname

echo "127.0.0.1   localhost
::1         localhost
127.0.1.1   yu.localdomain yu" >> /etc/hosts

echo "input passwd(root)"

passwd root

useradd -m -G wheel -s /bin/fish -p yuhao yu

visudo /etc/sudoers

echo "set up the systemd-boot manual"
