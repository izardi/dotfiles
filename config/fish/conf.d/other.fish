function proxy
  set -gx ALL_PROXY http://127.0.0.1:2080
end

function noproxy
  set -e ALL_PROXY
end

abbr -a rm rm -i
abbr -a fet neofetch
abbr -a gg g++ -std=c++26 -Wall -pedantic -fsanitize=address -g
abbr -a cl clang++ -std=c++26 -stdlib=libc++ -Wall -pedantic -fsanitize=address -g
abbr -a mvi mpv --config-dir=/home/yu/.config/mpv-image-viewer
abbr -a za zathura
abbr -a cr cargo run
