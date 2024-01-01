
function proxy
  set -xg ALL_PROXY http://localhost:20172
end

function noproxy
  set -e ALL_PROXY
end
