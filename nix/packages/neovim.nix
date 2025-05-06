{ neovim-unwrapped
, source
}:

neovim-unwrapped.overrideAttrs(self: super: {
  version = source.rev;
  src = source // { tag = source.rev; } ;
})
