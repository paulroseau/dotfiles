{
  pkgs
}:

with pkgs;

let 
  c = [
    clang
    clang-tools
    cmake
  ];

  go = [
    gopls
  ];

  lua = [
    lua-language-server
  ];

in
  c 
  ++ lua
  ++ go
