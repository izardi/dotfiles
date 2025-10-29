# fcitx
set -x INPUT_METHOD fcitx
set -x SDL_IM_MODULE fcitx

# color
set -xU MANPAGER 'less -R --use-color -Dd+g -Du+b -DE+r -DC+m -DS+y -DP+c'
set -xU MANROFFOPT '-P -c'

# Electron
set -x ELECTRON_OZONE_PLATFORM_HINT wayland

# SDL
set -x SDL_VIDEODRIVER wayland
set -x CLUTTER_BACKEND wayland

# XDG
set -x XDG_SESSION_TYPE wayland
set -x XDG_CURRENT_DESKTOP Niri
set -x XDG_SESSION_DESKTOP Niri

# GRIM defautl dir
# set -x GRIM_DEFAULT_DIR /home/yu/Pictures/Grim

# QT
set -x QT_QPA_PLATFORM wayland
set -x QT_QPA_PLATFORMTHEME qt6ct
set -x QT_WAYLAND_DISABLE_WINDOWDECORATION 1

if status is-interactive
    if test (tty) = "/dev/tty1"
        exec niri-session
    end
end
