# Neovim

- Read `notes/lua.md` first.

## Build

### Standard

- If you download the neovim sources, you will see that it is built with `cmake`. I didn't look into `cmake` but it looks like an enhanced version of `make`. In particular it allows you to specify where to download dependencies and build them. If you look in the `cmake.deps/` directory you will see that there is code to download the source code of each libary needed both at runtime (`lua`, `libuv`, etc.) and build time (`gettext`, etc.). You will also see that it defines the option `USE_BUNDLED` and `USE_BUNDLED_<SPECIFIC_LIB>` which controls whether those dependencies sources are downloaded and built or whether the linker will use the ones already present on your system.

- If you download `nvim` from Github with the following script
  ```
  cd $(mktemp -d)
  curl -LO https://github.com/neovim/neovim/releases/download/v0.9.0/nvim-linux64.tar.gz
  tar -zxf nvim-linux64.tar.gz
  cd nvim-linux64/bin
  ```
  and check its linked libraries with `readelf -d ./nvim` you won't see any shared library (no lua libraries in particular) but the standard ones of your OS
  ```
  Tag        Type                         Name/Value
  0x0000000000000001 (NEEDED)             Shared library: [libm.so.6]
  0x0000000000000001 (NEEDED)             Shared library: [libpthread.so.0]
  0x0000000000000001 (NEEDED)             Shared library: [libdl.so.2]
  0x0000000000000001 (NEEDED)             Shared library: [libgcc_s.so.1]
  0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
  0x0000000000000001 (NEEDED)             Shared library: [ld-linux-x86-64.so.2]
  0x0000000000000001 (NEEDED)             Shared library: [libutil.so.1]
  0x000000000000000c (INIT)               0x8d000
  0x000000000000000d (FINI)               0x478a10
  ...
  ```
  I think this is because by default they did download all the libraries source code and embedded them in the `nvim` executable. Indeed this executable is twice as big as the one built in nix which links dynamically to libraries (cf. below):
  ```
  $ du -h ./nvim
  9.6M    nvim
  $ du -h $(readlink -f $(which nvim))
  4.7M    /nix/store/xh2bnl13wsj2vj3bpziwyjdqzlc50vdq-neovim-unwrapped-0.8.3/bin/nvim
  ```

### With nix

- On nix the opposite is done, libraries already built locally are linked at build time through (`neovim/default.nix`)
  ```
  cmakeFlags = [
    # Don't use downloaded dependencies. At the end of the configurePhase one
    # can spot that cmake says this option was "not used by the project".
    # That's because all dependencies were found and
    # third-party/CMakeLists.txt is not read at all.
    "-DUSE_BUNDLED=OFF"
  ]
  ```

- With nix the environment hooks from the wrapped `binutils` are run against all `buildInputs` in order to patch `-rpath` of the executable being with the `./lib` directory of all `buildinput`. (For details check general notes). Hence we see a different result:
  ```
  Tag        Type                         Name/Value
  0x0000000000000001 (NEEDED)             Shared library: [libluv.so.1]
  0x0000000000000001 (NEEDED)             Shared library: [libuv.so.1]
  0x0000000000000001 (NEEDED)             Shared library: [libdl.so.2]
  0x0000000000000001 (NEEDED)             Shared library: [librt.so.1]
  0x0000000000000001 (NEEDED)             Shared library: [libmsgpackc.so.2]
  0x0000000000000001 (NEEDED)             Shared library: [libvterm.so.0]
  0x0000000000000001 (NEEDED)             Shared library: [libtermkey.so.1]
  0x0000000000000001 (NEEDED)             Shared library: [libunibilium.so.4]
  0x0000000000000001 (NEEDED)             Shared library: [libtree-sitter.so.0]
  0x0000000000000001 (NEEDED)             Shared library: [libm.so.6]
  0x0000000000000001 (NEEDED)             Shared library: [libutil.so.1]
  0x0000000000000001 (NEEDED)             Shared library: [libluajit-5.1.so.2]
  0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
  0x000000000000001d (RUNPATH)            Library runpath: [/nix/store/nlhfwa5y0ypi2l9pgsg0gd57sy87x3xk-libtermkey-0.22/lib:/nix/store/zzbig6s0jjj46lpl479fnkdqf16n15cw-libuv-1.45.0/lib:/nix/store/b99p0llx1iyfm9im6asyh9yrm0nvbv22-libvterm-neovim-0.3.2/lib:/nix/store/4w4xwln25hi0hflp639yrcw0r1kv3ysj-libluv-1.44.2-1/lib:/nix/store/qks07qazzfjx4816bal8gqv4mpldv9sw-msgpack-3.3.0/lib:/nix/store/aig7gndp8h0g6x77272zgm6hyxgvlrp2-luajit-2.1.0-2022-10-04-env/lib:/nix/store/9i8mldfza7yzv9h91p72jvidnf4dkkbr-tree-sitter-0.20.8/lib:/nix/store/9kmqdik9dc69fpgqvh0k6h96wgqnpgfy-unibilium-2.1.1/lib:/nix/store/wpgrc564ys39vbyv0m50qxmq8dvhi7cc-glibc-2.37-8/lib]
  ...
  ```

- Note that in `buildInputs` there is more than the standard `lua` derivation (holding just `lib/libluajit-5.1.so` and `bin/lua` inside), there are lua packages added  (simplified below):
  ```
  neovimLuaEnv = lua.withPackages(ps: [ ps.lpeg ps.luabitop ps.mpack ])
  ```
  `neovimLuaEnv` is passed as a `buildInput` for `neovim`. However I believe this is a bit of a mix of concerns because the `lib/libluajit-5.1.so` of the resulting lua env (which is just a link to the standalone `lua` derivation without any packages) is used at runtime (so should be in `buildInputs`), while the `bin/lua` binary whose `LUA_PATH` is patched to be able to discover the packages - since it is part of an environment (check notes/lua.md) - will be use only at build time, hence should be in `nativeBuildInput`.

- The reason why those `lpeg`, `luabitop` and `mpack` packages are added to `lua` is because they are needed at build time to perform some code generation when building neovim (look for `require lpeg` in the neovim source code for example, you will see it only in `./generators` folder). Also check `CMakeList.txt` at the root of the source code:
  ```
  # Find Lua interpreter
  include(LuaHelpers)
  set(LUA_DEPENDENCIES lpeg mpack bit)
  ```

- You can check that the resulting `nvim` executable will ONLY be able to load `lib/libluajit-5.1.so` at runtime through its `RUNPATH` (not `lib/lua/5.1/lpeg.so` and other packages since `ld` will just look under `/nix/store/aig7gndp8h0g6x77272zgm6hyxgvlrp2-luajit-2.1.0-2022-10-04-env/lib` not under `/nix/store/aig7gndp8h0g6x77272zgm6hyxgvlrp2-luajit-2.1.0-2022-10-04-env/lib/lua/5.1`):
  ```
  ls /nix/store/aig7gndp8h0g6x77272zgm6hyxgvlrp2-luajit-2.1.0-2022-10-04-env
  ▾ lib/
    ▾ lua/5.1/
        bit.so* -> /nix/store/yw82ssxj39f1ymww602sn5r4chkf0qg9-luajit2.1-luabitop-1.0.2-3/lib/lua/5.1/bit.so [RO]
        lpeg.so* -> /nix/store/cxy1dd7brlfwq5lixd5njh2k1i2659rh-luajit2.1-lpeg-1.0.2-1/lib/lua/5.1/lpeg.so [RO]
        mpack.so* -> /nix/store/6q1dnfnd0ggmxwk71p8rlcrncxgxnfsm-luajit2.1-mpack-1.0.9-0/lib/lua/5.1/mpack.so [RO]
      libluajit-5.1.so* -> /nix/store/ldjanqzjxn68wyfnnxmqaa3sik945sr9-luajit-2.1.0-2022-10-04/lib/libluajit-5.1.so.2.1.0 [RO]
  ```
  You can check that also by seeing that `lua require("lpeg")` fails inside `nvim`. This is expected, because `nvim` is built against the library `libluajit.so` which links to the pure liblua (not in the lua env and hence has no knowledge of packages in the environment). The environment just has an effect on the `LUA_CPATH` and `LUA_PATH` of the binaries - not the libs - which are used only during the building of neovim but not at runtime (the library is).

- (However since the nix build `liblua.so` has the `LUA_CPATH` patched to `./lib/lua/${luaversion}/?.so;./?.so;./lib/lua/${luaversion}/loadall.so` (check `notes/lua.md` and run `:lua print(package.cpath)`) if you launch `nvim` from inside `/nix/store/aig7gndp8h0g6x77272zgm6hyxgvlrp2-luajit-2.1.0-2022-10-04-env` specifically `lua require("lpeg")` will work)

## Runtime

- `nvim` loads vim files and lua files from specific subdirectories (`autoload`, `doc`, etc.) in any directory listed in the `runtimepath`. The runtimepath is set to a default value, check `:help runtimepath`. One thing that is not mentioned in the document is that `../lib` relatively to the absolute path of the `nvim` executable is also in the `runtimepath`.

- Examples:
  - Standalone neovim downloaded from Github:
    ```
    # Downloading
    cd $(mktemp -d)
    curl -LO https://github.com/neovim/neovim/releases/download/v0.9.0/nvim-linux64.tar.gz
    tar -zxf nvim-linux64.tar.gz
    cd nvim-linux64/bin
    # Checking rtp
    ./nvim
    :set rtp?
    ```
    Result:
    ```
    runtimepath=
    ~/.config/nvim
    /etc/xdg/nvim
    ~/.local/share/nvim/site
    /usr/share/gnome/nvim/site
    /usr/local/share/nvim/site
    /usr/share/nvim/site
    /tmp/tmp.xpImZjsMNM/nvim-linux64/share/nvim/runtime
    /tmp/tmp.xpImZjsMNM/nvim-linux64/share/nvim/runtime/pack/dist/opt/matchit
    /tmp/tmp.xpImZjsMNM/nvim-linux64/lib/nvim
    /usr/share/nvim/site/after
    /usr/local/share/nvim/site/after
    /usr/share/gnome/nvim/site/after
    ~/.local/share/nvim/site/after
    /etc/xdg/nvim/after
    ~/.config/nvim/after
    ```
    As mentioned in `:help VIMRUNTIME`, `$VIMRUNTIME` is set by default to `../share/nvim/runtime` relative to `v:progpath` (the absolute directory of `nvim`), hence in this case `/tmp/tmp.xpImZjsMNM/nvim-linux64/share/nvim/runtime` is in the runtimepath. We notice that `/tmp/tmp.xpImZjsMNM/nvim-linux64/lib/nvim` is also in there, which is not mentioned in `:help rtp`
    Other example trying to modify `$VIMRUNTIME` by setting the `$VIMRUNTIME` environment variable
    ```
    VIMRUNTIME="/toto" ./nvim
    :set rtp?
    ```
    Result
    ```
    ~/.config/nvim
    /etc/xdg/nvim
    ~/.local/share/nvim/site
    /usr/share/gnome/nvim/site
    /usr/local/share/nvim/site
    /usr/share/nvim/site
    /toto
    /tmp/tmp.xpImZjsMNM/nvim-linux64/lib/nvim
    /usr/share/nvim/site/after
    /usr/local/share/nvim/site/after
    /usr/share/gnome/nvim/site/after
    ~/.local/share/nvim/site/after
    /etc/xdg/nvim/after
    ~/.config/nvim/after 
    ```
    Hence we deduce that `nvim` by default adds `/abs/path/to/nvim/../lib/nvim` to the runtimepath
  - For `nvim` built with nix:
    ```
    nvim
    :set rtp?
    ```
    Result:
    ```
    ~/.config/nvim
    /etc/xdg/nvim
    ~/.local/share/nvim/site
    /usr/share/gnome/nvim/site
    /usr/local/share/nvim/site
    /usr/share/nvim/site
    /nix/store/xh2bnl13wsj2vj3bpziwyjdqzlc50vdq-neovim-unwrapped-0.8.3/share/nvim/runtime
    /nix/store/xh2bnl13wsj2vj3bpziwyjdqzlc50vdq-neovim-unwrapped-0.8.3/share/nvim/runtime/pack/dist/opt/matchit
    /nix/store/xh2bnl13wsj2vj3bpziwyjdqzlc50vdq-neovim-unwrapped-0.8.3/lib/nvim
    /usr/share/nvim/site/after
    /usr/local/share/nvim/site/after
    /usr/share/gnome/nvim/site/after
    ~/.local/share/nvim/site/after
    /etc/xdg/nvim/after
    ~/.config/nvim/after
    ```
    and overriding default `$VIMRUNTIME`
    ```
    VIMRUNTIME="/toto" nvim
    :set rtp?
    ```
    Result:
    ```
    ~/.config/nvim
    /etc/xdg/nvim
    ~/.local/share/nvim/site
    /usr/share/gnome/nvim/site
    /usr/local/share/nvim/site
    /usr/share/nvim/site
    /toto
    /nix/store/xh2bnl13wsj2vj3bpziwyjdqzlc50vdq-neovim-unwrapped-0.8.3/lib/nvim
    /usr/share/nvim/site/after
    /usr/local/share/nvim/site/after
    /usr/share/gnome/nvim/site/after
    ~/.local/share/nvim/site/after
    /etc/xdg/nvim/after
    ~/.config/nvim/after
    ```
    Which confirms the default behaviour of `nvim`

- According to `:help require`, lua in nvim is able to load any `.lua` file or `.so` (extentions in `LUA_CPATH` actually) in the `./lua` directories that sit under any path in the `runtimepath`. Check `:help require` for more details.

- According to `:help lua-package-path`, it seems that the `:lua print(package.path)` and `:lua print(package.cpath)` do not reflect the values computed from `runtimepath`, it only does after updates to runtimepath (not sure though as none of these directories contain any `./lua` folder when testing so far - to double check).
  Also check `:help lua-package-path`, `:help package.path`, `:help package.cpath`, `:help luaref-require`.

- Check `:help initialization` to understand what `nvim` does when booting. In particular, `init.lua` is read pretty late, but you can still disable some automatic loading from there by turning off `vim.go.filetype = false`, `vim.go.syntax = false` or `vim.go.loadplugins = false`. 

- The latter will prevent the automatic sourcing of files located in `share/nvim/runtime/plugin` such as (`gzip.vim` - to read gzip files automatically, `matchit.vim` - to highlight matching parenthesis automatically, etc.) and files in `share/nvim/runtime/pack/*/start/*` (none by default). The lazy.lua plugin manager disables the `loadplugin` option, might be a good idea to do so as well.

- In the neovim source code in `./nvim/lua/executor.c` you will see that the lua environment (of type `lua_State`) is initialized. A lot of functions for the external libraries (`libuv` via `libluv`, `treesitter`, etc.) are pushed inside that environment, so they are available when running lua inside neovim. For instance for the `vim.loop` table, it is defined as so in `lua/executor.c`:
  ```
  luaopen_luv(lstate); # libluv is a library that provides bindings to libuv library from lua
  lua_pushvalue(lstate, -1);
  lua_setfield(lstate, -3, "loop");
  ```

## Note on the lazy, mason and nvim-treesitter plugins

- These plugins allow you to pull code and install it (in the case of `nvim-treesitter` this involves compilation of C code to generate the `parser.so`).

- Since this is exactly what nix aims to be used for and we want to have fine control on what we install on the system, let's just use nix for those functionalities even if it means writing you own code for it.

## Note on floating windows

- Floating windows is a capability added by Neovim. To create one you just need
  to invoke  `vim.api.nvim_open_win({buffer}, {enter}, {*config})` where `config = {relative='win', row=3, col=3, width=12, height=3}`. The window can be relative to the editor, current window, cursor and mouse. It is very much like any other window, it is just that you can not navigate in and out of it with the usual `C-w h/j/k/l` mappings.

## Internals

- vim.loop, is an instantiation of a Libluv loop. It is actually grabbed through [luv](https://github.com/luvit/luv) which is a lua wrapper around the [libluv library](https://github.com/libuv/libuv) which itself is a wrapper around various Unix OS and Windows to expose a uniform API to do Asynchronous programming (things like reading files, networking, forking threads, etc.). It was originally built for NodeJS. Its model is using one event loop, which is polled using the OS native polling mechanism (for Linux it uses the `epoll` system call under the hood for example).

- `vim.schedule_wrap` grabs a function `cb` and returns a function which will schedule that function on the vim.loop with `vim.schedule`. You can check the source code at `runtime/lua/vim/_editor.lua`:
    ```lua
    function vim.schedule_wrap(fn)
      return function(...)
        local args = vim.F.pack_len(...)
        vim.schedule(function()
          fn(vim.F.unpack_len(args))
        end)
      end
    end
    ```
