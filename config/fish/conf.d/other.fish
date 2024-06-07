function proxy
  set -gx ALL_PROXY http://127.0.0.1:20173
end

function noproxy
  set -e ALL_PROXY
end

abbr -a fet neofetch
abbr -a gg g++ -std=c++2c
abbr -a cl clang++ -std=c++2c

abbr -a mvi mpv --config-dir=/home/yu/.config/mpv-image-viewer
