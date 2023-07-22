set -x CLUTTER_BACKEND wayland
set -x XDG_CURRENT_DESKTOP sway
set -x XDG_SESSION_DESKTOP sway
set -x _JAVA_AWT_WM_NONREPARENTING 1

function proxy
  set -xg ALL_PROXY http://localhost:20172
end

function noproxy
  set -e ALL_PROXY
end
