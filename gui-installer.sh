#! /bin/bash

#username=""

#################
#   Functions   #
#################

# paru install

# Green text print.
print () {
    echo -e "\x1b[1;32m$1\e[0m"
}

# Blue text print info.
print_i () {
    echo -e "\x1b[1;94m[i] $1\e[0m"
}

# Blue text print info (without the [i]).
print_b () {
    echo -e "\x1b[1;94m$1\e[0m"
}

# Yellow text print warnings.
print_w () {
    echo -e "\x1b[0;33m[w] $1\e[0m"
}

# Yellow text print warnings (without the [w]).
print_y () {
    echo -e "\x1b[0;33m$1\e[0m"
}

# Check if script is being ran as root and exit if it isn't.
root_check () {
    if [ "$EUID" -ne 0 ] 
        then 
        print_w "Please run this script as root."
        print_y "\nIf you would like to delete this script,"
        print_y "please login as root and hit (n/N) when asked to continue."
        sleep 10.0s
        exit
    fi
}

# Welcome screen.
welcome () {
    print "##############################"
    print "#                            #"
    print "#   Mocha's GUI Installer    #"
    print "#                            #"
    print "#   Author: Mochabear97      #"
    print "#   Version: 1.0.0           #"
    print "#                            #"
    print "##############################"
    print "\nWelcome $username"
    echo -e "\n"
    print_i "This script allows you to install paru, some packages,"
    print_b "and select a desktop environment or window manager to install."
}

# Ask the user if they want to install this script.
continue_check () {
    read -r -p "[?] Would you like to continue? (y/n): " choice
    case $choice in
        [Yy] ) print "continuing..."
               sleep 3.0s
               ;;
          "" ) print "continuing..."
               sleep 3.0s
               ;;
        [Nn] ) print_i "Removing script and exiting..."
               sleep 3.0s
               rm -rf /etc/profile.d/gui-installer.sh
               exit
               ;;
           * ) print_w "You did not enter a valid selection."
               continue_check
    esac
}

# Ask user about AUR support. Install if yes.
paru_install () {
    clear
    print "Would you like to install paru for AUR support?"
    echo -e "\n"
    print_i "The Arch User Repositories feature thousands"
    print_b "of packages not features in the main repos."
    echo -e "\n"
    print_w "Many packages the script that runs after reboot"
    print_y "require AUR support. They will be labeled (AUR)."
    read -r -p "Answer (y/n): " choice
    case $choice in
        [Nn] ) clear
               print_w "You did not install paru. Most of the packages"
               print_y "in this script require AUR support in order to be installed"
               print_y "labeled (AUR) will not be installable."
               sleep 10.0s
               ;;
        [Yy] ) clear
               print "Installing paru now..."
               print_i "Some credentials may be required for $username"
               sleep 5.0s
               pacman -S --noconfirm rust cargo
               sudo -u "$username" git clone https://aur.archlinux.org/paru.git /home/"$username"/paru
               cd /home/"$username"/paru || return
               sudo -u "$username" makepkg -i
               rm -rf /home/"$username"/paru
               cd || return
               sleep 3.0s
               ;;
        "" ) clear
             print "Installing paru now..."
             print_i "Some credentials may be required for $username"
             sleep 5.0s
             pacman -S --noconfirm rust cargo
             sudo -u "$username" git clone https://aur.archlinux.org/paru.git /home/"$username"/paru
             cd /home/"$username"/paru || return
             sudo -u "$username" makepkg -i
             rm -rf /home/"$username"/paru
             cd || return
             sleep 3.0s
    esac
}

# Select whether to install a desktop environment or window manager.
gui_selector () {
    clear
    print "***GUI Menu***"
    print "\n0) Deskop Environment (beginners)."
    print "1) Window Manager (advanced users)."
    read -r -p "Please select which to install (0/1): " choice
    case $choice in
        0 ) GUISELECTION="Desktop Environment"
            gui_check
            ;;
        1 ) GUISELECTION="Window Manager"
            gui_check
            ;;
        * ) print_w "You did not enter a valid selection."
            sleep 2.0s
            gui_selector
    esac
}

# Check whether user selected the right GUI to install.
gui_check () {
    read -r -p"[?] You selected $GUISELECTION is this correct? (y/n)" choice
    case $choice in
        [Yy] ) print "continuing..."
               sleep 2.0s
               de_wm
               ;;
         "" ) print "continuing..."
               sleep 2.0s
               de_wm
               ;;
        [Nn] ) print_i "Please try again."
               sleep 3.0s
               gui_selector
    esac
}

# Check which GUI was selected run corresponding function.
de_wm () {
    if [ "$GUISELECTION" == "Desktop Environment" ]
        then
        de_select
    fi

    if [ "$GUISELECTION" == "Window Manager" ]
        then
        wm_select
    fi
}

# DE environment selection
de_select () {
  clear
  print "**Desktop Environments Menu**"
  print "\n1) Cinnamon"
  print "2) GNOME"
  print "3) KDE"
  print "4) XFCE"
  print "0) [CANCEL] (Return to GUI select screen.)"
  read -r -p "Please select an option (0-4): " choice
  case $choice in
    0 ) print "Returning to GUI select screen..."
        sleep 3.0s
        gui_selector
	    ;;
    1 )	DE="Cinnamon"
        clear
        print "You Selected $DE"
        echo -e "\n"
        print_i "$DE is a desktop environment best suited for"
        print_b "users who are most comfortable with Windows 7"
	    de_selection_check
	    ;;
    2 ) DE="GNOME"
        clear
	    print "You Selected $DE"
        echo -e "\n"
        print_i "$DE is a very simplistic modern desktop environment"
        print_b "best suited for users who are used to OSX(Macintosh)"
	    de_selection_check
	    ;;
    3 ) DE=KDE
        clear
	    print "You Selected $DE"
        echo -e "\n"
        print_i "$DE is a very modern desktop environment built"
        print_b "with Windows 10/11 users in mind"
	    de_selection_check
        ;;
    4 ) DE="XFCE"
        clear
        print "You Selected $DE"
        echo -e "\n"
	    print_i "$DE is an older desktop environment closely resembling"
        print_b "Windows XP in terms of look and feel."
        echo -e "\n"
        print_i "This DE is best suited for computers with older hardware."
        de_selection_check
	    ;;
    * ) print_w "That is not a valid selection."
        print_y "Please try again."
        sleep 2.0s
	    de_select
  esac
}

# DE Selection Check
de_selection_check () {
  read -r -p "[?] Is this correct? (y/n): " choice
  case $choice in
    "" ) sleep 2.0s
         de_wm_package_selector
        ;;
    [Yy] ) sleep 2.0s
           de_wm_package_selector
	       ;;
    [Nn] ) sleep 2.0s
           de_select
	       ;;
    * ) print_w "Please try again."
        de_selection_check
  esac
}

# Window manager selection
wm_select () {
  clear
  print "**Window Manager Menu**"
  print "\n1) Awesome"
  print "2) BSPWM"
  print "3) DWM"
  print "4) i3-Gaps"
  print "5) Sway"
  print "6) XMonad"
  print "0) [CANCEL] (Return to GUI select screen.)"
  read -r -p "Please select an option: " choice
  case $choice in
    0 ) print "Returing to GUI select screen..."
        sleep 3.0s
        gui_selector
        ;;
    1 )	WM="Awesome"
        clear
        print "You selected $WM Window Manager"
        echo -e "\n"
        print_i "$WM WM is written and configured in lua and uses"
        print_b "the asynchronous XCB library instead of the old synchronous Xlib."
        echo -e "\n"
        print_w "Some knowledge in the lua language is recommended"
        print_y "please check awesomewm.org for more information."
	    wm_selection_check
	    ;;
    2 ) WM="BSPWM"
        clear
	    print "You selected $WM Window Manager"
        echo -e "\n"
        print_i "$WM is a fibonacci spiralling WM written in C and mainly configued"
        print_b "in shell script but can be configured in any language you chose."
        print_b "Uses the asynchornous XCB library instead of Xlib."
        echo -e "\n"
        print_w "This window manager has a difficult learning curve."
        print_y "and is not suited for the faint of heart."
        print_y "Please keep in mind that $WM also has limited layouts."
        echo -e "\n"
        print_w "Please check the $WM github page for more details."
        print_y "If you chose to install BSPWM please read the man"
        print_y "pages for $WM and BSPC for more help."
	    wm_selection_check
	    ;;
    3 ) WM="DWM"
        clear
	    print "You Selected $WM Window Manager"
        echo -e "\n"
        print_i "$WM is built around the suckless philosophy of doing one thing,"
        print_b "and doing it right. This WM is written and configured in C."
        echo -e "\n"
        print_w "Some knowledge in the c language is required to configure"
        print_y "this WM. Config file (config.h) must be recompiles whenever"
        print_y "making configuration changes. See dwm.suckless.org"
        print_y "for more informations."
	    wm_selection_check
        ;;
    4 ) WM="i3"
        clear
        print "You Selected $WM Window Manager"
        echo -e "\n"
	    print_i "$WM WM is written in C. $WM is the simplest WM"
        print_b "for first time WM users as it is configured in a"
        print_b "simple scripting language very similar to english."
        print_b "\nPlease check i3wm.org for more information."
        wm_selection_check
	    ;;
    5 ) WM="Sway"
        clear
        print "You Selected $WM Window Manager"
        echo -e "\n"
	    print "$WM is drop in replacement for i3 WM written for Wayland."
        echo -e "\n"
        print_w "\nIf you are an Nvidia user please do not install this"
        print_y "WM at the moment as Wayland is not well supported on"
        print_y "these GPUs"
        print_y "Please check phoronix.com for updates on Nvidia"
        print_y "drivers in linux if you are interested in this wm."
        wm_selection_check
	    ;;
    6 ) WM="XMonad"
        clear
        print "You Selected $WM"
        echo -e "\n"
	    print_i "$WM is a highly extensible WM written and configured in haskell."
        print_b "Haskell is a purely functional programming language."
        print_b "XMonad includes a contib which will also be installed, filled"
        print_b "with many modifications created by the community."
        echo -e "\n"
        print_w "Haskell is a very difficult programming language for those"
        print_y "unfamiliar to programming. If you are unfamiliar with it"
        print_y "please do some research first before picking this WM. Also check,"
        print_y "xmonad.org for more information."
        wm_selection_check
	    ;;
    * ) print_w "That is not a valid selection."
        print_y "Please try again."
        sleep 2.0s
	    wm_select
  esac
}

# WM selection check
wm_selection_check () {
  read -r -p "[?] Is this correct? (y/n): " choice
  case $choice in
    "" ) sleep 2.0s
         de_wm_package_selector
         ;;
    [Yy] ) sleep 2.0s
           de_wm_package_selector
           ;;
    [Nn] ) sleep 2.0s
	       clear
           wm_select
	       ;;
    * ) print_w "Please try again."
        wm_selection_check
  esac
}

de_wm_package_selector() {
    if [ $DE == "Cinnamon" ] || [ $DE == "GNOME" ] || [ $DE == "XFCE" ]
        then
        package_selector_1
    fi
    if [ $DE == "KDE" ]
        then
        package_selector_2
    fi
    if [ -n "$WM" ]
        then
        package_selector_3
    fi
}

#########################
#   Package Selectors   #
#########################

# Package selector 1 (Cinnamon, GNOME, XFCE)
package_selector_1 () {
    clear
    print "***Main Menu***"
    print "\n1) Audio (Audio Software)"
    print "2) Browser (Web Browsers)"
    print "3) Email (Email clients)"
    print "4) Gaming (Gaming Software)"
    print "5) Graphics (Graphics software)"
    print "6) Office (Office Suites)"
    print "7) [DONE] (Don't install any more packages.)"
    print "0) [EXIT] (Exit the script.)"
    read -r -p "Please select a menu to select applications (0-7): " choice
    case $choice in
        0 ) print "Exiting...."
            sleep 3.0s
            exit
            ;;
        1 ) audio_1
            ;;
        2 ) browser_1
            ;;
        3 ) email_1
            ;;
        4 ) gaming_1
            ;;
        5 ) graphics_1
            ;;
        6 ) office_1
            ;;
        7 ) install_de
            ;;
        * ) print_w "Please try again."
            sleep 2.0s
            main_menu
    esac
}

# Package selector 2 (KDE)
package_selector_2 () {
    clear
    print "***Main Menu***"
    print "\n1) Audio: Audio Software"
    print "2) Browser: Web Browser"
    print "3) Email: Email clients"
    print "4) Gaming: Gaming Software"
    print "5) Graphics: Graphics software"
    print "6) Office: Office Suites"
    print "7) [DONE] (Don't install any more packages.)"
    print "0) [EXIT] (Exit the script.)"
    read -r -p "Please select a menu (0-7): " choice
    case $choice in
        0 ) print "Exiting..."
            sleep 3.0s
            exit
            ;;
        1 ) audio_2
            ;;
        2 ) browser_2
            ;;
        3 ) email_2
            ;;
        4 ) gaming_2
            ;;
        5 ) graphics_2
            ;;
        6 ) office_2
            ;;
        7 ) install_de
            ;;
        * ) print_w "Please try again."
            sleep 2.0s
            main_menu
    esac
}

# Package selector 3 (WM)
package_selector_3 () {
    clear
    print "***Main Menu***"
    print "\n1) Audio: Audio software"
    print "2) Browser: Web browsers"
    print "3) Email: Email clients"
    print "4) FM: File Managers"
    print "5) Gaming: Gaming software"
    print "6) Graphics: Graphics software"
    print "7) Office: Office suites"
    print "8) Shell: Shell environemnts"
    print "9) Terminal: Terminal emulators"
    print "10) Editor: TUI text editors"
    print "11) [DONE] (Don't install any more packages.)"
    print "0) [EXIT] (Exit the script.)"
    read -r -p "Please select a menu (0-11): " choice
    case $choice in
        0 ) print "Exiting..."
            sleep 3.0s
            exit
            ;;
        1 ) audio_3
            ;;
        2 ) browser_3
            ;;
        3 ) email_3
            ;;
        4 ) file_manager
            ;;
        5 ) gaming_3
            ;;
        6 ) graphics_3
            ;;
        7 ) office_3
            ;;
        8 ) shell_env
            ;;
        9 ) terminal_emulator
            ;;
        10 ) text_editor
             ;;
        11 ) install_wm
             ;;
        * ) print_w "Please try again."
            sleep 2.0s
            main_menu
    esac
}

####################
#   Menu 1 Items   #
####################

# Audio packages menu.
audio_1 () {
    clear
    print "***Audio Software***"
    print "\n1) cmus"
    print "2) Lollypop"
    print "3) Rhythmbox"
    print "4) Spotify (GIT)"
    print "0) [NONE] (Main Menu)"
    read -r -p "Please select one (0-4): " choice
    case $choice in
        0 ) print_i "Returning to main menu..."
            sleep 2.0s
            package_selector_1
            ;;
        1 ) clear
            print_i "Installing cmus..."
            pacman -S cmus
            sleep 2.0s
            audio_1
            ;;
        2 ) clear
            print_i "Installing Lollypop..."
            pacman -S lollypop
            sleep 2.0s
            audio_1
            ;;
        3 ) clear
            print_i "Installing Rhythmbox..."
            pacman -S rhythmbox
            sleep 2.0s
            audio_1
            ;;
        4 ) clear
            print_i "Installing Spotify..."
            curl -sS https://download.spotify.com/debian/pubkey_5E3C45D7B312C643.gpg | gpg --import -
            sudo -u "$username" git clone https://aur.archlinux.org/spotify.git /home/"$username"/spotify
            cd /home/"$username"/spotify || return
            sudo -u "$username" makepkg -i
            rm -rf /home/"$username"/spotify
            cd || return
            sleep 2.0s
            audio_1
            ;;
        * ) print_w "\nNot a valid selection"
            sleep 3.0s
            audio_1
    esac
}

# Browser packages menu.
browser_1 () {
    clear
    print "***Web Browsers***"
    print "\n1) Brave (AUR)"
    print "2) Chromium"
    print "3) Edge: currently in beta (AUR)"
    print "4) Firefox"
    print "0) [NONE] (Main Menu)"
    read -r -p "Please select one (0-4): " choice
    case $choice in
        0 ) print_i "Returning to main menu..."
            sleep 2.0s
            package_selector_1
            ;;
        1 ) clear
            print_i "Installing Brave..."
            sudo -u "$username" paru -S brave-bin
            sleep 2.0s
            browser_1
            ;;
        2 ) clear
            print_i "Installing Chromium..."
            pacman -S chromium
            sleep 2.0s
            browser_1
            ;;
        3 ) clear
            print_i "Installing Edge..."
            sudo -u "$username" paru -S microsoft-edge-beta-bin
            sleep 2.0s
            browser_1
            ;;
        4 ) clear
            print_i "Installing Firefox..."
            pacman -S firefox
            sleep 2.0s
            browser_1
            ;;
        * ) print_w "\nNot a valid selection"
            sleep 3.0s
            browser_1
    esac
}

# Email packages menu.
email_1 () {
    clear
    print "***Email Clients***"
    print "\n1) Evolution"
    print "2) Geary"
    print "3) Mutt (advanced user only)"
    print "4) Neomutt (advanced users only)"
    print "5) Thunderbird"
    print "0) [NONE] (Main Menu)"
    read -r -p "Please select one (0-5): " choice
    case $choice in
        0 ) print_i "Returning to main menu..."
            sleep 2.0s
            package_selector_1
            ;;
        1 ) clear
            print_i "Installing Evolution..."
            pacman -S evolution
            sleep 2.0s
            email_1
            ;;
        2 ) clear
            print_i "Installing Geary..."
            pacman -S geary
            sleep 2.0s
            email_1
            ;;
        3 ) clear
            print_i "Installing Mutt..."
            pacman -S mutt
            sleep 2.0s
            email_1
            ;;
        4 ) clear
            print_i "Installing Neomutt..."
            pacman -S neomutt
            sleep 2.0s
            email_1
            ;;
        5 ) clear
            print_i "Installing Thunderbird..."
            pacman -S thunderbird
            sleep 2.0s
            email_1
            ;;
        * ) print_w "\nNot a valid selection"
            sleep 3.0s
            email_1
    esac
}

# Gaming packages menu.
gaming_1 () {
    clear
    print "***Gaming Software***"
    print "\n1) Lutris"
    print "2) Steam"
    print "0) [NONE] (Main Menu)"
    read -r -p "Please select one (0-2): " choice
    case $choice in
        0 ) print_i "Returning to main menu..."
            sleep 2.0s
            package_selector_1
            ;;
        1 ) clear
            print_i "Installing Lutris..."
            pacman -S lutris
            sleep 2.0s
            gaming_1
            ;;
        2 ) clear
            print_i "Installing Steam..."
            pacman -S steam ttf-liberation
            sleep 2.0s
            gaming_1
            ;;
        * ) print_w "\nNot a valid selection."
            sleep 3.0s
            gamming_1
    esac
}

# Graphics packages menu.
graphics_1 () {
    clear
    print "***Graphics Software***"
    print "\n1) GIMP"
    print "2) Inkscape"
    print "0) [NONE] (Main Menu)"
    read -r -p "Please select one (0-2): " choice
    case $choice in
        0 ) print_i "Returning to main menu..."
            sleep 2.0s
            package_selector_1
            ;;
        1 ) clear
            print_i "Installing GIMP..."
            pacman -S gimp
            sleep 2.0s
            graphics_1
            ;;
        2 ) clear
            print_i "Installing Inkscape..."
            pacman -S inkscape
            sleep 2.0s
            graphics_1
            ;;
        * ) print_w "\nNot a valid selection"
            sleep 3.0s
            graphics_1
    esac
}

# Office packages menu.
office_1 () {
    clear
    print "***Office Suites***"
    print "\n1) LibreOffice-Fresh (Development)"
    print "2) LibreOffice-Still (LTS)"
    print "0) [NONE] (Main Menu)"
    read -r -p "Please select one (0-2): " choice
    case $choice in
        0 ) print_i "Returning to main menu..."
            sleep 2.0s
            package_selector_1
            ;;
        1 ) clear
            print_i "Installing LibreOffice-Fresh..."
            pacman -S coin-or-mp libmythes libpaper libwpg pstoedit unixodbc sane libreoffice-fresh
            sleep 2.0s
            office_1
            ;;
        2 ) clear
            print_i "Installing LibreOffice-Still..."
            pacman -S coin-or-mp libmythes libpaper libwpg pstoedit unixodbc sane libreoffice-still
            sleep 2.0s
            office_1
            ;;
        * ) print_w "\nNot a valid selection."
            sleep 3.0s
            office_1
    esac
}

####################
#   Menu 2 Items   #
####################

# Audio packages menu.
audio_2 () {
    clear
    print "***Audio Software***"
    print "\n1) Audacious"
    print "2) cmus"
    print "3) Elisa (Also installs vlc)"
    print "4) Spotify (GIT)"
    print "0) [NONE] (Main Menu)"
    read -r -p "Please select one (0-4): " choice
    case $choice in
        0 ) print_i "Returning to main menu..."
            sleep 2.0s
            package_selector_2
            ;;
        1 ) clear
            print_i "Installing Audacious..."
            pacman -S audacious
            sleep 2.0s
            audio_2
            ;;
        2 ) clear
            print_i "Installing cmus..."
            pacman -S cmus
            sleep 2.0s
            audio_2
            ;;
        3 ) clear
            print_i "Installing Elisa..."
            pacman -S elisa
            sleep 2.0s
            audio_2
            ;;
        4 ) clear
            print_i "Installing Spotify..."
            curl -sS https://download.spotify.com/debian/pubkey_5E3C45D7B312C643.gpg | gpg --import -
            sudo -u "$username" git clone https://aur.archlinux.org/spotify.git /home/"$username"/spotify
            cd /home/"$username"/spotify || return
            sudo -u "$username" makepkg -i
            rm -rf /home/"$username"/spotify
            cd || return
            sleep 2.0s
            audio_2
            ;;
        * ) print_w "\nNot a valid selection."
            sleep 3.0s
            audio_2
    esac
}

# Browser packages menu.
browser_2 () {
    clear
    print "***Web Browsers***"
    print "\n1) Brave (AUR)"
    print "2) Chromium"
    print "3) Edge: currently in beta (AUR)"
    print "4) Falkon"
    print "5) Firefox"
    print "0) [NONE] (Main Menu)"
    read -r -p "Please select one (0-5): " choice
    case $choice in
        0 ) print_i "Returning to main menu..."
            sleep 2.0s
            package_selector_2
            ;;
        1 ) clear
            print_i "Installing Brave..."
            sudo -u "$username" paru -S brave-bin
            sleep 2.0s
            browser_2
            ;;
        2 ) clear
            print_i "Installing Chromium..."
            pacman -S chromium
            sleep 2.0s
            browser_2
            ;;
        3 ) clear
            print_i "Installing Edge..."
            paru -S microsoft-edge-beta-bin
            sleep 2.0s
            browser_2
            ;;
        4 ) clear
            print_i "Installing Falkon..."
            pacman -S falkon
            sleep 2.0s
            browser_2
            ;;
        5 ) clear
            print_i "Installing Firefox..."
            pacman -S firefox
            sleep 2.0s
            browser_2
            ;;
        * ) print_w "\nNot a valid selection"
            sleep 3.0s
            browser_2
    esac
}

# Email packages menu.
email_2 () {
    clear
    print "***Email Clients***"
    print "\n1) Kmail"
    print "2) Mutt (advanced user only)"
    print "3) Neomutt (advanced users only)"
    print "4) Thunderbird"
    print "0) [NONE] (Main Menu)"
    read -r -p "Please select one (0-4): " choice
    case $choice in
        0 ) print_i "Returning to main menu..."
            sleep 2.0s
            package_selector_2
            ;;
        1 ) clear
            print_i "Installing Kmail..."
            pacman -S kmail
            sleep 2.0s
            email_2
            ;;
        2 ) clear
            print_i "Installing Mutt..."
            pacman -S mutt
            sleep 2.0s
            email_2
            ;;
        3 ) clear
            print_i "Installing Neomutt..."
            pacman -S neomutt
            sleep 2.0s
            email_2
            ;;
        4 ) clear
            print_i "Installing Thunderbird..."
            pacman -S thunderbird
            sleep 2.0s
            email_2
            ;;
        * ) print_w "\nNot a valid selection"
            sleep 3.0s
            email_2
    esac
}

# Gaming packages menu.
gaming_2 () {
    clear
    print "***Gaming Software***"
    print "\n1) Lutris"
    print "2) Steam"
    print "0) [NONE] (Main Menu)"
    read -r -p "Please select one (0-2): " choice
    case $choice in
        0 ) print_i "Returning to main menu..."
            sleep 2.0s
            package_selector_2
            ;;
        1 ) clear
            print_i "Installing Lutris..."
            pacman -S lutris
            sleep 2.0s
            gaming_2
            ;;
        2 ) clear
            print_i "Installing Steam..."
            pacman -S steam ttf-liberation
            sleep 2.0s
            gaming_2
            ;;
        * ) print_w "\nNot a valid selection."
            sleep 3.0s
            gaming_2
    esac
}

# Graphics packages menu.
graphics_2 () {
    clear
    print "***Graphics Software***"
    print "\n1) Krita"
    print "2) Inkscape"
    print "0) [NONE] (Main Menu)"
    read -r -p "Please select one (0-2): " choice
    case $choice in
        0 ) print_i "Returning to main menu..."
            sleep 2.0s
            package_selector_2
            ;;
        1 ) clear
            print_i "Installing Krita..."
            pacman -S krita
            sleep 2.0s
            graphics_2
            ;;
        2 ) clear
            print_i "Installing Inkscape..."
            pacman -S inkscape
            sleep 2.0s
            graphics_2
            ;;
        * ) print_w "\nNot a valid selection"
            sleep 3.0s
            graphics_2
    esac
}

# Office packages menu.
office_2 () {
    clear
    print "***Office Suites***"
    print "\n1) Calligra Suite"
    print "2) LibreOffice-Fresh (Development)"
    print "3) LibreOffice-Still (LTS)"
    print "0) [NONE] (Main Menu)"
    read -r -p "Please select one (0-3): " choice
    case $choice in
        0 ) print_i "Returning to main menu..."
            sleep 2.0s
            package_selector_2
            ;;
        1 ) clear
            print_i "Installing Calligra Suite..."
            pacman -S libmythes libpaper libwpg pstoedit unixodbc sane calligra
            sleep 2.0s
            office_2
            ;;
        2 ) clear
            print_i "Installing LibreOffice-Fresh..."
            pacman -S coin-or-mp libmythes libpaper libwpg pstoedit unixodbc sane libreoffice-still
            sleep 2.0s
            office_2
            ;;
        3 ) clear
            print_i "Installing LibreOffice-Still..."
            pacman -S coin-or-mp libmythes libpaper libwpg pstoedit unixodbc sane libreoffice-still
            sleep 2.0s
            office_2
            ;;
        * ) print_w "\nNot a valid selection"
            sleep 3.0s
            office_2
    esac
}

####################
#   Menu 3 Items   #
####################

# Audio packages menu.
audio_3 () {
    clear
    print "***Audio Software***"
    print "\n1) cmus"
    print "2) Lollypop"
    print "3) Rhythmbox"
    print "4) Ncspot (AUR)"
    print "5) Spotify (GIT)"
    print "0) [NONE] (Main Menu)"
    read -r -p "Please select one (0-4): " choice
    case $choice in
        0 ) print_i "Returning to main menu..."
            sleep 2.0s
            package_selector_3
            ;;
        1 ) clear
            print_i "Installing cmus..."
            pacman -S cmus
            sleep 2.0s
            audio_3
            ;;
        2 ) clear
            print_i "Installing Lollypop..."
            pacman -S lollypop
            sleep 2.0s
            audio_3
            ;;
        3 ) clear
            print_i "Installing Rhythmbox..."
            pacman -S rhythmbox
            sleep 2.0s
            audio_3
            ;;
        4 ) clear
            print_i "Installing Ncspot..."
            sudo -u "$username" paru -S ncspot
            sleep 2.0s
            audio_3
            ;;
        5 ) clear
            print_i "Installing Spotify..."
            curl -sS https://download.spotify.com/debian/pubkey_5E3C45D7B312C643.gpg | gpg --import -
            sudo -u "$username" git clone https://aur.archlinux.org/spotify.git /home/"$username"/spotify
            cd /home/"$username"/spotify || return
            sudo -u "$username" makepkg -i
            rm -rf /home/"$username"/spotify
            cd || return
            sleep 2.0s
            audio_3
            ;;
        * ) print_w "\nNot a valid selection"
            sleep 3.0s
            audio_3
    esac
}

# Browser packages menu.
browser_3 () {
    clear
    print "***Web Browsers***"
    print "\n1) Brave (AUR)"
    print "2) Chromium"
    print "3) Edge: currently in beta (AUR)"
    print "4) Firefox"
    print "0) [NONE] (Main Menu)"
    read -r -p "Please select one (0-4): " choice
    case $choice in
        0 ) print_i "Returning to main menu..."
            sleep 2.0s
            package_selector_3
            ;;
        1 ) clear
            print_i "Installing Brave..."
            sudo -u "$username" paru -S brave-bin
            sleep 2.0s
            browser_3
            ;;
        2 ) clear
            print_i "Installing Chromium..."
            pacman -S chromium
            sleep 2.0s
            browser_3
            ;;
        3 ) clear
            print_i "Installing Edge..."
            sudo -u "$username" paru -S microsoft-edge-beta-bin
            sleep 2.0s
            browser_3
            ;;
        4 ) clear
            print_i "Installing Firefox..."
            pacman -S firefox
            sleep 2.0s
            browser_3
            ;;
        * ) print_w "\nNot a valid selection"
            sleep 3.0s
            browser_3
    esac
}

# Email packages menu.
email_3 () {
    clear
    print "***Email Clients***"
    print "\n1) Evolution"
    print "2) Geary"
    print "3) Mutt (advanced user only)"
    print "4) NeoMutt (advanced users only)"
    print "5) Thunderbird"
    print "0) [NONE] (Main Menu)"
    read -r -p "Please select one (0-5): " choice
    case $choice in
        0 ) print_i "Returning to main menu..."
            sleep 2.0s
            package_selector_3
            ;;
        1 ) clear
            print_i "Installing Evolution..."
            pacman -S evolution
            sleep 2.0s
            email_3
            ;;
        2 ) clear
            print_i "Installing Geary..."
            pacman -S geary
            sleep 2.0s
            email_3
            ;;
        3 ) clear
            print_i "Installing Mutt..."
            pacman -S mutt
            sleep 2.0s
            email_3
            ;;
        4 ) clear
            print_i "Installing Neomutt..."
            pacman -S neomutt
            sleep 2.0s
            email_3
            ;;
        5 ) clear
            print_i "Installing Thunderbird..."
            pacman -S thunderbird
            sleep 2.0s
            email_3
            ;;
        * ) print_w "\nNot a valid selection"
            sleep 3.0s
            email_3
    esac
}

file_manager () {
    clear
    print "***File Managers***"
    print "\n1) nnn (TUI)"
    print "2) pcmanfm (GUI)"
    print "3) ranger (TUI)"
    print "4) thunar (GUI)"
    print "0) [NONE] (Main Menu)"
    read -r -p "Please select one (0-4): " choice
    case $choice in
        0 ) print_i "Returning to main menu..."
            sleep 2.0s
            package_selector_3
            ;;
        1 ) clear
            print_i "Installing nnn..."
            pacman -S nnn
            sleep 2.0s
            file_manager
            ;;
        2 ) clear
            print_i "Installing pcmanfm..."
            pacman -S pcmanfm
            sleep 2.0s
            file_manager
            ;;
        3 ) clear
            print_i "Installing ranger..."
            paru -S ranger
            sleep 2.0s
            file_manager
            ;;
        4 ) clear
            print_i "Installing thunar..."
            pacman -S thunar
            sleep 2.0s
            file_manager
            ;;
        * ) print_w "\nNot a valid selection"
            sleep 3.0s
            file_manager
    esac
}

# Gaming packages menu.
gaming_3 () {
    clear
    print "***Gaming Software***"
    print "\n1) Lutris"
    print "2) Steam"
    print "0) [NONE] (Main Menu)"
    read -r -p "Please select one (0-2): " choice
    case $choice in
        0 ) print_i "Returning to main menu..."
            sleep 2.0s
            package_selector_3
            ;;
        1 ) clear
            print_i "Installing Lutris..."
            pacman -S lutris
            sleep 2.0s
            gaming_3
            ;;
        2 ) clear
            print_i "Installing Steam..."
            pacman -S steam ttf-liberation
            sleep 2.0s
            gaming_3
            ;;
        * ) print_w "\nNot a valid selection."
            sleep 3.0s
            gaming_3
    esac
}

# Graphics packages menu.
graphics_3 () {
    clear
    print "***Graphics Software***"
    print "\n1) GIMP"
    print "2) Inkscape"
    print "0) [NONE] (Main Menu)"
    read -r -p "Please select one (0-2): " choice
    case $choice in
        0 ) print_i "Returning to main menu..."
            sleep 2.0s
            package_selector_3
            ;;
        1 ) clear
            print_i "Installing GIMP..."
            pacman -S gimp
            sleep 2.0s
            graphics_3
            ;;
        2 ) clear
            print_i "Installing Inkscape..."
            pacman -S inkscape
            sleep 2.0s
            graphics_3
            ;;
        * ) print_w "\nNot a valid selection"
            sleep 3.0s
            graphics_3
    esac
}

# Office suite packages menu.
office_3 () {
    clear
    print "***Office Suites***"
    print "\n1) LibreOffice-Fresh (Development)"
    print "2) LibreOffice-Still (LTS)"
    print "0) [NONE] (Main Menu)"
    read -r -p "Please select one (0-2): " choice
    case $choice in
        0 ) print_i "Returning to main menu..."
            sleep 2.0s
            package_selector_3
            ;;
        1 ) clear
            print_i "Installing LibreOffice-Fresh..."
            pacman -S coin-or-mp libmythes libpaper libwpg pstoedit unixodbc sane libreoffice-fresh
            sleep 2.0s
            office_3
            ;;
        2 ) clear
            print_i "Installing LibreOffice-Still..."
            pacman -S coin-or-mp libmythes libpaper libwpg pstoedit unixodbc sane libreoffice-still
            sleep 2.0s
            office_3
            ;;
        * ) print_w "\nNot a valid selection"
            sleep 3.0s
            office_3
    esac
}

shell_env () {
    clear
    print "***Shell Environments***"
    print "\n1) fish"
    print "2) zsh"
    print "0) [NONE] (Main Menu)"
    read -r -p "Please select one (0-2): " choice
    case $choice in
        0 ) print_i "Returning to main menu..."
            sleep 2.0s
            package_selector_3
            ;;
        1 ) clear
            print_i "Installing fish..."
            pacman -S fish
            sleep 2.0s
            shell_env
            ;;
        2 ) clear
            print_i "Installing zsh..."
            pacman -S zsh
            sleep 2.0s
            shell_env
            ;;
        * ) print_w "\nNot a valid selection."
            sleep 3.0s
            shell_env
    esac
}

# Terminal emulator package menu.
terminal_emulator () {
    clear
    print "***Terminal Emulators***"
    print "\n1) Alacritty"
    print "2) cool-retro-term"
    print "3) kitty"
    print "4) rxvt-unicode"
    print "5) xterm"
    print "0) [NONE] (Main Menu)"
    read -r -p "Please select one and only one (0-5): " choice
    case $choice in
        0 ) print_i "Returning to main menu..."
            echo -e "\n"
            print_w "Keep in mind that a window manager"
            print_y "requires a terminal emulator to function."
            sleep 6.0s
            package_selector_3
            ;;
        1 ) clear
            print_i "Installing Alacritty..."
            pacman -S alacritty
            sleep 2.0s
            terminal_emulator
            ;;
        2 ) clear
            print_i "Installing cool-retro-term..."
            pacman -S cool-retro-term
            sleep 2.0s
            terminal_emulator
            ;;
        3 ) clear
            print_i "Installing kitty..."
            pacman -S kitty
            sleep 2.0s
            terminal_emulator
            ;;
        4 ) clear
            print_i "Installing rxvt-unicode..."
            pacman -S rxvt-unicode
            sleep 2.0s
            terminal_emulator
            ;;
        5 ) clear
            print_i "Installing xterm..."
            pacman -S xterm
            sleep 2.0s
            terminal_emulator
            ;;
        * ) print_w "\nNot a valid selection."
            sleep 3.0s
            terminal_emulator
    esac
}

text_editor () {
    clear
    print "***Text Editors***"
    print "\n1) Atom"
    print "2) Emacs"
    print "3) Kakoune"
    print "4) Nano"
    print "5) Neovim"
    print "6) Vim"
    print "7) VScode (AUR)"
    print "0) [NONE] (Main Menu)"
    read -r -p "Please select one (0-7): " choice
    case $choice in
        0 ) print_i "Returning to main menu..."
            echo -e "\n"
            print_w "Keep in mind that a window manager"
            print_y "requires a text editor to function."
            sleep 2.0s
            package_selector_3
            ;;
        1 ) clear
            print_i "Installing Atom..."
            pacman -S atom
            sleep 2.0s
            text_editor
            ;;
        2 ) clear
            print_i "Installing Emacs..."
            pacman -S emacs
            sleep 2.0s
            text_editor
            ;;
        3 ) clear
            print_i "Installing Kakoune..."
            pacman -S kakoune
            sleep 2.0s
            text_editor
            ;;
        4 ) clear
            print_i "Installing Nano..."
            pacman -S nano
            sleep 2.0s
            text_editor
            ;;
        5 ) clear
            print_i "Installing Neovim..."
            pacman -S neovim
            sleep 2.0s
            text_editor
            ;;
        6 ) clear
            print_i "Installing Vim..."
            pacman -S vim
            sleep 2.0s
            text_editor
            ;;
        7 ) clear
            print_i "Installing VScode"
            sudo -u "$username" paru -S visual-studio-code-bin
            sleep 2.0s
            text_editor
            ;;
        * ) print_w "\nNot a valid selection."
            sleep 3.0s
            text_editor
    esac

}

# Installation of desired DE if selected
install_de () {
    clear
    if [ "$DE" == "Cinnamon" ]
        then
        clear
        print "$DE desktop environemnt will now be installed."
        print "Along with some other usefull applications..."
        sleep 3.0s
        clear
        pacman -S --noconfirm archlinux-appstream-data audacity binutils \
            blueberry bottom bzip2 cinnamon cups cups-pdf dpkg exa \
            file-roller galculator gnome-disk-utility gnome-keyring \
            gnome-terminal gpick gvfs libmythes lightdm \
            lightdm-gtk-greeter lollypop meld neofetch networkmanager \
            network-manager-applet npm p7zip papirus-icon-theme pavucontrol \
            pulseaudio redshift simple-scan system-config-printer ufw \
            unrar vlc wget xed xdg-utils xdg-user-dirs xorg-server xreader zip zsh
        clear
        print "Some Systemd services will now be enabled..."
        sleep 2.0s
        sed -i 's/#logind-check-graphical=false/logind-check-graphical=true/g' /etc/lightdm/lightdm.conf
        sed -i 's/#greeter-session=example-gtk-gnome/greeter-session=lightdm-gtk-greeter/g' /etc/lightdm/lightdm.conf
        systemctl enable bluetooth.service
        systemctl enable cups.socket
        systemctl enable lightdm.service
        systemctl enable NetworkManager.service
        systemctl enable ufw.service
        sleep 3.0s
    fi

    if [ "$DE" == "GNOME" ]
        then
        clear
        print "$DE desktop environment will now be installed."
        print "Along with some other usefull applications..."
        sleep 5.0s
        clear
        pacman -S --noconfirm archlinux-appstream-data audacity binutils bluez \
            bottom bzip2 cups cups-pdf dpkg exa gimp gnome gpick materia-gtk-theme \
            meld neofetch networkmanager npm p7zip papirus-icon-theme pulseaudio \
            simple-scan system-config-printer ufw unrar vlc wget xdg-utils \
            xorg-server zip zsh
        clear
        print "\nSome Systemd services will now be enabled..."
        sleep 2.0s
        systemctl enable bluetooth.service
        systemctl enable cups.socket
        systemctl enable gdm.service
        systemctl enable NetworkManager.service
        systemctl enable ufw.service
        sleep 3.0s
    fi

    if [ "$DE" == "KDE" ]
        then
        clear
        print "$DE desktop environment will now be installed."
        print "Along with some other usefull applications..."
        sleep 3.0s
        clear
        pacman -S --noconfirm archlinux-appstream-data ark audacity binutils \
            bluedevil bottom breeze-gtk bzip2 cups cups-pdf dolphin dpkg \
            drkonqi exa filelight gnome-keyring gwenview kalarm kate \
            kcalc kcolorchooser kde-gtk-config kdeplasma-addons kdiff3 kgamma5 \
            khelpcenter khotkeys kinfocenter kmag knotes konsole korganizer kscreen \
            ksshaskpass kwallet-pam kwayland-integration kwrited neofetch networkmanager \
            npm okular oxygen p7zip plasma-desktop plasma-disks plasma-firewall plasma-nm  \
            plasma-pa plasma-systemmonitor plasma-thunderbolt plasma-vault \
            plasma-workspace-wallpapers sddm-kcm skanlite spectacle \
            system-config-printer ufw unrar wget xdg-desktop-portal-kde \
            xdg-utils xdg-user-dirs xorg-server zip zsh
        clear
        print "\nSome Systemd services will now be enabled..."
        sleep 2.0s
        systemctl enable bluetooth.service
        systemctl enable cups.socket
        systemctl enable NetworkManager.service
        systemctl enable sddm.service
        systemctl enable ufw.service
        sleep 3.0s
    fi

    if [ "$DE" == "XFCE" ]
        then
        clear
        print "$DE desktop environment will now be installed."
        print "Along with some other usefull applications..."
        sleep 3.0s
        clear
        pacman -S --noconfirm archlinux-appstream-data audacity binutils \
            blueman bottom bzip2 cups cups-pdf dpkg exa galculator \
            gnome-disk-utility gnome-keyring gpick gvfs libcanberra \
            lightdm lightdm-gtk-greeter meld neofetch networkmanager \
            network-manager-applet npm p7zip papirus-icon-theme pavucontrol \
            picom pstoedit pulseaudio redshift simple-scan system-config-printer \
            ufw unrar vlc wget xarchiver xdg-utils xdg-user-dirs xfce4 xfce4-goodies zip zsh
        clear
        print "Some Systemd services will now be enabled..."
        sleep 2.0s
        sed -i 's/#logind-check-graphical=false/logind-check-graphical=true/g' /etc/lightdm/lightdm.conf
        sed -i 's/#greeter-session=example-gtk-gnome/greeter-session=lightdm-gtk-greeter/g' /etc/lightdm/lightdm.conf
        systemctl enable bluetooth.service
        systemctl enable cups.socket
        systemctl enable lightdm.service
        systemctl enable NetworkManager.service
        systemctl enable ufw.service
        sleep 3.0s
    fi

}

# Installation of desired WM if selected
install_wm () {
    if [ "$WM" == "Awesome" ]
        then
        clear
        print "$WM window manager will now be installed."
        print "Along with some other usefull applications..."
        sleep 3.0s
        pacman -S --noconfirm archlinux-appstream-data arandr audacity awesome blueman \
            bottom bzip2 cups cups-pdf dmenu dpkg dunst feh galculator gnome-disk-utility \
            gpick gvfs lxappearance-gtk3 lxsession maim meld mpv networkmanager \
            nm-connection-editor network-manager-applet npm p7zip papirus-icon-theme \
            pavucontrol picom pulseaudio redshift rofi simple-scan starship \
            system-config-printer transmission-gtk ttf-hack \
            ttf-nerd-fonts-symbols ufw unrar wget wireless_tools \
            xarchiver xautolock xclip xdg-utils xfce4-power-manager \
            xorg-server xorg-xprop xorg-xinit xorg-xsetroot youtube-dl \
            zathura zathura-pdf-mupdf zathura-ps zip

        clear
        print "Some initializitaion is occuring, please wait..."
        print_i "Some credentials may be required for $username."
        sleep 5.0s
        sudo -u "$username" cp /etc/X11/xinit/xinitrc /home/"$username"/.xinitrc
        sudo -u "$username" sed -i 's/^twm.*//g' /home/"$username"/.xinitrc
        sudo -u "$username" sed -i 's/^xterm.*//g' /home/"$username"/.xinitrc
        sudo -u "$username" sed -i 's/^exec.*/exec awesome/' /home/"$username"/.xinitrc
        sudo -u "$username" mkdir -p /home/"$username"/.config/awesome/
        sudo -u "$username" cp /etc/xdg/awesome/rc.lua /home/"$username"/.config/awesome/
        clear
        print_i "Some Systemd services will now be enabled..."
        systemctl enable bluetooth.service
        systemctl enable cups.socket
        systemctl enable lightdm.service
        systemctl enable NetworkManager.service
        systemctl enable ufw.service
        sleep 3.0s
        clear
        print_i "$WM Window Manager installation complete!"
        sleep 3.0s
    fi

    if [ "$WM" == "BSPWM" ]
        then
        clear
        print "$WM will now be installed."
        print "Along with some other usefull applications..."
        sleep 3.0s
        pacman -S --noconfirm archlinux-appstream-data arandr audacity blueman bottom bspwm bzip2 \
            cups cups-pdf dmenu dpkg dunst feh galculator gnome-disk-utility \
            gpick gvfs lxappearance-gtk3 lxsession maim meld mpv networkmanager \
            nm-connection-editor network-manager-applet npm p7zip papirus-icon-theme \
            pavucontrol picom pulseaudio redshift rofi simple-scan starship \
            sxhkd system-config-printer transmission-gtk ttf-hack \
            ttf-nerd-fonts-symbols ufw unrar wget wireless_tools \
            xarchiver xautolock xclip xdg-utils xfce4-power-manager \
            xorg-server xorg-xprop xorg-xinit xorg-xsetroot youtube-dl \
            zathura zathura-pdf-mupdf zathura-ps zip
        clear
        read -r -p "Please enter the name of the terminal you will be using: " choice
        case $choice in
            Alacritty ) term_choice=Alacritty
                        ;;
            cool-retro-term ) term_choice=cool-retro-term
                              ;;
            kitty ) term_choice=kitty
                    ;;
            rxvt-unicode ) term_choice=rxvt-unicode
                            ;;
            xterm ) term_choice=xterm
                    ;;
            * ) print_w "You did not enter a valid selection please try again."
                read -r -p "Please enter the name of the terminal you will be using: " choice   
        esac
        clear
        print "Some initialization is occuring, please wait..."
        print_i "Some information may be required for $username"
        sleep 5.0s
        sudo -u "$username" install -Dm755 /usr/share/doc/bspwm/examples/bspwmrc \
        /home/"$username"/.config/bspwm/bspwmrc
        sudo -u "$username" install -Dm644 /usr/share/doc/bspwm/examples/sxhkdrc \
        /home/"$username"/.config/sxhkd/sxhkdrc
        sudo -u "$username" sed -i "s/urxvt/$term_choice/" /home/"$username"/.config/sxhkd/sxhkdrc
        sudo -u "$username" cp /etc/X11/xinit/xinitrc /home/"$username"/.xinitrc
        sudo -u "$username" sed -i 's/^twm.*//g' /home/"$username"/.xinitrc
        sudo -u "$username" sed -i 's/^xterm.*//g' /home/"$username"/.xinitrc
        sudo -u "$username" sed -i 's/^exec.*/exec bspwm/' /home/"$username"/.xinitrc
        clear
        print_i "Some Systemd services will now be enabled..."
        systemctl enable bluetooth.service
        systemctl enable cups.socket
        systemctl enable lightdm.service
        systemctl enable NetworkManager.service
        systemctl enable ufw.service
        sleep 3.0s
        clear
        print_i "$WM installation complete!"
        sleep 3.0s
    fi

    if [ "$WM" == "DWM" ]
        then
        clear
        print "$WM will now be installed."
        print "Along with some other usefull applications..."
        print_i "Some credentials may be required for $username"
        sleep 5.0s
        sudo -u "$username" git clone https://git.suckless.org/dwm/ /home/"$username"/dwm/
        cd /home/"$username"/dwm/ || return
        sudo -u "$username" make
        sudo -e "$username" make install
        cd || return
        pacman -S --noconfirm archlinux-appstream-data arandr audacity blueman bottom bzip2 \
            cups cups-pdf dmenu dpkg dunst feh galculator gnome-disk-utility \
            gpick gvfs lxappearance-gtk3 lxsession maim meld mpv networkmanager \
            nm-connection-editor network-manager-applet npm p7zip papirus-icon-theme \
            pavucontrol picom pulseaudio redshift simple-scan starship \
            system-config-printer transmission-gtk ttf-hack \
            ttf-nerd-fonts-symbols ufw unrar wget wireless_tools \
            xarchiver xautolock xclip xdg-utils xfce4-power-manager \
            xorg-server xorg-xprop xorg-xinit xorg-xsetroot youtube-dl \
            zathura zathura-pdf-mupdf zathura-ps zip
        clear
        print "Some initialization is occuring, please wait..."
        print_i "Some credentials may be required for $username."
        sleep 5.0s
        sudo -u "$username" cp /etc/X11/xinit/xinitrc /home/"$username"/.xinitrc
        sudo -u "$username" sed -i 's/^twm.*//g' /home/"$username"/.xinitrc
        sudo -u "$username" sed -i 's/^xterm.*//g' /home/"$username"/.xinitrc
        sudo -u "$username" sed -i 's/^exec.*/exec dwm/' /home/"$username"/.xinitrc
        clear
        print "Some Systemd services will now be enabled..."
        systemctl enable bluetooth.service
        systemctl enable cups.socket
        systemctl enable lightdm.service
        systemctl enable NetworkManager.service
        systemctl enable ufw.service
        sleep 3.0s
        clear
        print_i "$WM installation complete!"
        sleep 3.0s
    fi

    if [ "$WM" == "i3-Gaps" ]
        then
        clear
        print "$WM window manager will now be installed."
        print "Along with some other usefull applications..."
        sleep 3.0s
        clear
        pacman -S --noconfirm archlinux-appstream-data arandr audacity blueman bottom bzip2 \
            cups cups-pdf dmenu dpkg dunst feh galculator gnome-disk-utility \
            gpick gvfs i3-gaps i3status i3lock lxappearance-gtk3 lxsession maim meld mpv networkmanager \
            nm-connection-editor network-manager-applet npm p7zip papirus-icon-theme \
            pavucontrol picom pulseaudio redshift rofi simple-scan starship \
            system-config-printer transmission-gtk ttf-hack \
            ttf-nerd-fonts-symbols ufw unrar wget wireless_tools \
            xarchiver xautolock xclip xdg-utils xfce4-power-manager \
            xorg-server xorg-xprop xorg-xinit xorg-xsetroot youtube-dl \
            zathura zathura-pdf-mupdf zathura-ps zip
        clear
        print "Some initialization is occuring, please wait..."
        print_i "Some credentials may be required for $username"
        sleep 5.0s
        sudo -u "$username" cp /etc/X11/xinit/xinitrc /home/"$username"/.xinitrc
        sudo -u "$username" sed -i 's/^twm.*//g' /home/"$username"/.xinitrc
        sudo -u "$username" sed -i 's/^xterm.*//g' /home/"$username"/.xinitrc
        sudo -u "$username" sed -i 's/^exec.*/exec i3/' /home/"$username"/.xinitrc
        clear
        print_i "Some Systemd services will now be enabled..."
        systemctl enable bluetooth.service
        systemctl enable cups.socket
        systemctl enable lightdm.service
        systemctl enable NetworkManager.service
        systemctl enable ufw.service
        sleep 3.0s
        clear
        print_i "$WM Window Manager installation complete!"
        sleep 3.0s
    fi

    if [ "$WM" == "Sway" ]
        then
        clear
        print "$WM window manager will now be installed."
        print "Along with some other usefull applications..."
        sleep 3.0s
        pacman -S --noconfirm archlinux-appstream-data arandr audacity blueman bottom bzip2 \
            cups cups-pdf dmenu dpkg dunst feh galculator gnome-disk-utility \
            gpick gvfs lxappearance-gtk3 lxsession maim meld mpv networkmanager \
            nm-connection-editor network-manager-applet npm p7zip papirus-icon-theme \
            pavucontrol picom pulseaudio redshift rofi simple-scan starship \
            sway system-config-printer transmission-gtk ttf-hack \
            ttf-nerd-fonts-symbols ufw unrar wget wireless_tools \
            xarchiver xautolock xclip xdg-utils xfce4-power-manager \
            xorg-server xorg-xprop xorg-xinit xorg-xsetroot youtube-dl \
            zathura zathura-pdf-mupdf zathura-ps zip
        clear
        print_i "Some Systemd services will now be enabled..."
        systemctl enable bluetooth.service
        systemctl enable cups.socket
        systemctl enable lightdm.service
        systemctl enable NetworkManager.service
        systemctl enable ufw.service
        sleep 3.0s
        clear
        print_i "$WM Window Manager installation complete!"
        print_b "Type sway and hit [ENTER] to run sway after reboot."
        sleep 5.0s
    fi

    if [ "$WM" == "XMonad" ]
        then
        clear
        print "$WM window manager will now be installed."
        print "Along with some other usefull applications..."
        sleep 3.0s
        pacman -S --noconfirm archlinux-appstream-data arandr audacity blueman bottom bzip2 \
            cups cups-pdf dmenu dpkg dunst feh galculator gnome-disk-utility \
            gpick gvfs lxappearance-gtk3 lxsession maim meld mpv networkmanager \
            nm-connection-editor network-manager-applet npm p7zip papirus-icon-theme \
            pavucontrol picom pulseaudio redshift rofi simple-scan starship \
            system-config-printer transmission-gtk ttf-hack \
            ttf-nerd-fonts-symbols ufw unrar wget wireless_tools \
            xarchiver xautolock xclip xdg-utils xfce4-power-manager \
            xmonad xmonad-contrib xmobar xorg-server xorg-xprop xorg-xinit xorg-xsetroot \
            youtube-dl zathura zathura-pdf-mupdf zathura-ps zip
        clear
        read -r -p "Please enter the name of the terminal you will be using: " choice
        case $choice in
            Alacritty ) term_choice=Alacritty
                        ;;
            cool-retro-term ) term_choice=cool-retro-term
                              ;;
            kitty ) term_choice=kitty
                    ;;
            rxvt-unicode ) term_choice=rxvt-unicode
                            ;;
            xterm ) term_choice=xterm
                    ;;
            * ) print_w "You did not enter a valid selection please try again."
                read -r -p "Please enter the name of the terminal you will be using: " choice   
        esac
        clear
        print "Some initialization is occuring, please wait..."
        print_i "Some information may be required for $username"
        sleep 5.0s
        sudo -u "$username" mkdir /home/"$username"/.xmonad
        sudo -u "$username" touch /home/"$username"/xmonad/xmonad.hs
        sudo -u "$username" echo "import XMonad \nmain = xmonad def { terminal = $term_choice }" \
        | tee /home/"$username"/.xmonad/xmonad.hs
        sudo -u "$username" cp /etc/X11/xinit/xinitrc /home/"$username"/.xinitrc
        sudo -u "$username" sed -i 's/^twm.*//g' /home/"$username"/.xinitrc
        sudo -u "$username" sed -i 's/^xterm.*//g' /home/"$username"/.xinitrc
        sudo -u "$username" sed -i 's/^exec.*/exec xmonad/' /home/"$username"/.xinitrc
        clear
        print "Some Systemd services will now be enabled..."
        systemctl enable bluetooth.service
        systemctl enable cups.socket
        systemctl enable lightdm.service
        systemctl enable NetworkManager.service
        systemctl enable ufw.service
        sleep 3.0s
        clear
        print_i "$WM Window Manager installation complete!"
        sleep 3.0s
    fi
}

###############
#   Program   #
###############

# Check root first
root_check

# Start by clearing TTY
clear

# Installation
welcome
continue_check
paru_install
gui_selector
de_wm
de_wm_package_selector
install_de
install_wm

# End of script.
clear
print "Installation complete!"
print "Deleting script and rebooting in 15.0s"
sleep 15.0s

rm -rf /etc/profile.d/gui-installer.sh
reboot

# Exit script.
exit