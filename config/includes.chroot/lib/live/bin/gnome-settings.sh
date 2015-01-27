#!/bin/sh

gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.desktop.session idle-delay 0

#dconf write /org/gnome/shell/favorite-apps "['gnome-terminal.desktop', 'org.gnome.Nautilus.desktop']"
