#!/usr/bin/env bash

# Enable XWayland grab access for Citrix Workspace (Wfica)
gsettings set org.gnome.mutter.wayland xwayland-grab-access-rules "['Wfica']"
gsettings set org.gnome.mutter.wayland xwayland-allow-grabs true
