function proxy
  set -gx ALL_PROXY socks5://127.0.0.1:2080
  set -gx HTTP_PROXY http://127.0.0.1:2080
  set -gx HTTPS_PROXY http://127.0.0.1:2080
end

function noproxy
  set -e ALL_PROXY
  set -e HTTP_PROXY
  set -e HTTPS_PROXY
end

abbr -a rm rm -i
abbr -a fet macchina
abbr -a gg g++ -std=c++26 -Wall -pedantic -fsanitize=address,undefined -g
abbr -a cl clang++ -std=c++26 -stdlib=libc++ -Wall -pedantic -fsanitize=address,undefined -g
abbr -a mvi mpv --config-dir=/home/yu/.config/mpv/mpv-image-viewer
abbr -a za zathura
abbr -a cr cargo run
abbr -a pg pgcli -h db.zardi.eu.org -p 32026 -U postgres
