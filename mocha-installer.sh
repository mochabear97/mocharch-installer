#! /bin/bash

# A simple Arch Linux install script

#################
#   Functions   #
#################


# Blue text print.
print () {
    echo -e "\x1b[1;94m$1\e[0m"
}

# Yellow text print warnings.
print_w () {
    echo -e "\x1b[0;33m[w] $1\e[0m"
}

# Check if script is being ran as root and exit if it isn't.
root_check () {
    if [ "$EUID" -ne 0 ] 
        then 
        echo -e "Please run this sript as root."
        sleep 3.0s
        exit
    fi
}

# Welcome screen.
welcome () {
    print "##############################"
    print "#                            #"
    print "#   Mocha's Arch Installer   #"
    print "#                            #"
    print "#   Author: Mochabear97      #"
    print "#   Version: 1.0.0           #"
    print "#                            #"
    print "##############################"
}

# Ask the user if they want to install this script.
continue_check () {
    read -r -p "[?] Would you like to continue? (y/n): " choice
    case $choice in
        [Yy] ) print "continuing..."
               sleep 3.0s
               ;;
        [Nn] ) exit
               ;;
          "" ) print "continuing..."
               sleep 3.0s
               ;;
           * ) print_w "You did not enter a valid selection."
               continue_check
    esac
}

# Initialize the program after welcome.
intitialization () {
   clear
   print "Initializing..."
   timedatectl set-ntp true
   sleep 3.0s
}

# Selecting a disk to install Arch Linux on.
disk_selector () {
    clear
    print "Please select the disk where Arch Linux will be installed:"
    select ENTRY in $(lsblk -dpnoNAME|grep -P "/dev/sd|nvme|");
    do
        DISK=$ENTRY
        print "Arch Linux will be installed on $DISK"
        break
    done
}

# Check disk is correct (function).
disk_confirm () {
    read -r -p "This will delete the current partition table on $DISK. Do you agree? (y/n): " response
    case $response in
        [Yy] ) print "Wiping $DISK..."
               wipefs -af "$DISK"
               sgdisk -Zo "$DISK"
               sleep 3.0s
               ;;
        [""] ) print "Wiping $DISK..."
               wipefs -af "$DISK"
               sgdisk -Zo "$DISK"
               sleep 3.0s
               ;;
        [Nn] ) print "Exiting script..."
               sleep 3.0s
               exit
    esac
}

# Ask about memory size and set swap varriable accoringly.

# Creating a new partition scheme.
create_partitions () {
    clear
    print "Creating the partitions on $DISK..."
    parted -s "$DISK" \
        mklabel gpt \
        mkpart primary fat32 1MiB 251MiB \
        set 1 ESP on \
        mkpart primary linux-swap 251Mib 6.26GiB \
        mkpart primary ext4 6.26GiB 100% \
    sleep 5.0s
}

#format disk partitions
format_partitions () {
    clear
    print "Formatting partitions now..."

    mkfs.ext4 -F "$DISK"p3
    mkswap "$DISK"p2
    mkfs.fat -F 32 "$DISK"p1
    mount "$DISK"p3 /mnt
    mkdir /mnt/efi
    mount "$DISK"p1 /mnt/efi
    swapon "$DISK"p2

    sleep 5.0s
}

# Detect microcode (AMD/INTEL).
microcode_detector () {
    clear
    CPU=$(grep vendor_id /proc/cpuinfo)
    if [[ $CPU == *"AuthenticAMD"* ]]; then
        print "An AMD CPU has been detected, AMD microcode will be installed."
        sleep 3.0s
        microcode="amd-ucode"
    else
        print "An Intel CPU has been detected, Intel microcode will be installed."
        sleep 3.0s
        microcode="intel-ucode"
    fi
}

# Selecting a kernel to install. 
kernel_selector () {
    clear
    print "***Kernels***"
    print "1) Stable: Vanilla Linux kernel with a few specific Arch Linux patches applied"
    print "2) Hardened: A security-focused Linux kernel"
    print "3) LTS: Long-term support (LTS) Linux kernel"
    print "4) Zen: A Linux kernel optimized for desktop usage"
    read -r -p "Insert the number of the corresponding kernel. (1-4): " choice
    case $choice in
        1 ) kernel="linux"
            ;;
        2 ) kernel="linux-hardened"
            ;;
        3 ) kernel="linux-lts"
            ;;
        4 ) kernel="linux-zen"
            ;;
        * ) print "You did not enter a valid selection."
            sleep 3.0s
            clear
            kernel_selector
    esac
}

# Selecting network Utility.
network_selector () {
    clear
    print "***Network Utilities***"
    print "1) IWD: iNet wireless daemon is a wireless daemon for Linux written by Intel (WiFi-only)"
    print "2) NetworkManager: Universal network utility to automatically connect to networks (both WiFi and Ethernet)"
    print "3) dhcpcd: Basic DHCP client (Ethernet only or VMs)"
    print "4) I will do this on my own (only advanced users)"
    read -r -p "Insert the number of the corresponding networking utility. (1-4): " choice
    case $choice in
        1 ) print "Installing IWD."    
            pacstrap /mnt iwd
            sleep 2.0s
            print "Enabling IWD."
            systemctl enable iwd --root=/mnt &>/dev/null
            sleep 2.0s
            ;;
        2 ) print "Installing NetworkManager."
            pacstrap /mnt networkmanager
            sleep 2.0s
            print "Enabling NetworkManager."
            systemctl enable NetworkManager --root=/mnt &>/dev/null
            sleep 2.0s
            ;;
        3 ) print "Installing dhcpcd."
            pacstrap /mnt dhcpcd
            sleep 2.0s
            print "Enabling dhcpcd."
            systemctl enable dhcpcd --root=/mnt &>/dev/null
            sleep 2.0s
            ;; 
        4 ) ;;
        * ) print_w "You did not enter a valid selection."
            sleep 2.0s
            clear
            network_selector
    esac
}

# Basic install of Arch Linux.
basic_install () {
    clear
    print "Installing base system now..."
    sleep 3.0s

    pacstrap /mnt base $microcode $kernel linux-firmware grub efibootmgr \
    base-devel man-db man-pages nnn neovim sudo texinfo zsh
}

# Set a hostname for the new system.
hostname_selector () {
    clear
    read -r -p "Please enter the hostname: " hostname
    if [ -z "$hostname" ]; then
        print_w "You need to enter a hostname in order to continue."
        hostname_selector
    fi
    echo "$hostname" > /mnt/etc/hostname
}

# Generate fstab.
gen_stab () {
    clear
    print "Generating a new fstab..."
    genfstab -U /mnt >> /mnt/etc/fstab
    sleep 3.0s
}

# Select a language locale.
locale_selector () {
    clear
    read -r -p "Please insert the locale you use (format: xx_XX or enter empty to use en_US): " locale
    if [ -z "$locale" ]; then
        print_w "en_US will be used as default locale."
        locale="en_US"
    fi
    echo "$locale.UTF-8 UTF-8"  > /mnt/etc/locale.gen
    echo "LANG=$locale.UTF-8" > /mnt/etc/locale.conf
}

# Select a keyboard layout to be installed.
keyboard_selector () {
    clear
    read -r -p "Please insert the keyboard layout you use (Press enter to use US keyboard layout): " kblayout
    if [ -z "$kblayout" ]; then
        print_w "Default keyboard layout set to US."
        kblayout="us"
    fi
    echo "KEYMAP=$kblayout" > /mnt/etc/vconsole.conf
}

# configure new system.
system_setup () {
    clear
    print "Beginning system configuration..."
    sleep 3.0s
    print "\nSetting timezone..."
    arch-chroot /mnt ln -sf /usr/share/zoneinfo/"$(curl -s http://ip-api.com/line?fields=timezone)" \
    /etc/localtime &>/dev/null
    sleep 1.0s

    print "\nConfiguring system hardware clock..."
    arch-chroot /mnt hwclock --systohc
    sleep 1.0ss

    print "\nGenerating locales..."
    arch-chroot /mnt locale-gen &>/dev/null
    sleep 1.0s

    print "\nGenerating new initramfs..."
    arch-chroot /mnt mkinitcpio -P &>/dev/null
    sleep 1.0s

    print "\nInstalling grub bootloader..."
    arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/efi \
    --bootloader-id=GRUB &>/dev/null
    sleep 1.0s

    print "\nCreating grub config file..."
    arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg &>/dev/null
    sleep 1.0s
}

# Set root password.
root_set() {
    clear
    print "Please create a password for the root user."
    arch-chroot /mnt passwd root
    sleep 3.0s
}

# User creation.
create_user () {
  clear
  read -r -p "Please Enter a name for a user account (leave empty and press enter to skip): "  username
  if [ -n "$username" ]; then
    arch-chroot /mnt useradd -m "$username"
    print "\nPlease enter a password for the new user."
    arch-chroot /mnt passwd "$username"
    sleep 3.0s
    clear
    echo -e "\x1b[1;34mAdding\e[0m \x1b[0;33m$username\e[0m \x1b[1;34mwith root privileges.\e[0m"
    arch-chroot /mnt gpasswd -a "$username" adm
    arch-chroot /mnt gpasswd -a "$username" rfkill
    arch-chroot /mnt gpasswd -a "$username" wheel
    echo "$username  ALL=(ALL) ALL" >> /mnt/etc/sudoers.d/"$username"
    sleep 3.0s
  fi
}


###############
#   Program   #
###############

root_check

# Start by clearing the terminal
clear

# Installation
welcome
continue_check
intitialization
disk_selector
disk_confirm
create_partitions
format_partitions
microcode_detector
kernel_selector
network_selector
basic_install
hostname_selector
gen_stab
locale_selector
keyboard_selector
system_setup
root_set
create_user

# Print a message after installing then restarts the system.
clear
print "Installation of Arch Linux is now complete!"
print "Computer will now restart in 30.0s..."
sleep 30.0s

print "Exiting"
reboot
exit