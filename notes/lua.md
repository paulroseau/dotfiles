## Lua

- Lua is an "extensible extension language". In actual fact, lua is just a C library which defines structures such as a "Lua Stack" on which you can push lua code and retrieve results back. Other C programs can then link to this libary and make use of the Lua language inside them. For example the `lua` interpreter executable just  creates a Lua stack, parses content from the command line, updates the stack with the input and retreives value from it to write it to output. The `lua` interpreter is also written in C.

- You can extend `lua` in one C application which links against it by registering other C functions in the stack structure. Hence libraries in lua can be just plain `lua` code files which can be read by your progam and fed to the Lua stack living inside it, or `lua` code AND shared objects `.so` which hold C code to extend lua. Check https://luarocks.org/modules/hisham/luafilesystem for example.

- In the `liblua.so`, the `require` execution looks at the variables `packages.path` and `packages.cpath` which are set to the value of `LUA_PATH` and `LUA_CPATH` (set through header files or read from the corresponding environment variables)

- Functions can be imported from `.so` C library inside a Lua stack with the `loadlib`. The `loadlib` function defined in `liblua.so` will cause to dynamically load the first library whose name matches the argument and which is present in the `LUA_CPATH`. The usual approach to distribute a C library in lua is to create a stub lua file which runs `loadlib` and allow you to `require` that stub library. More details on this at: https://www.lua.org/pil/24.1.html

## Lua in nixpkgs

- Building the `liblua.so`, `luaconf.h` is patched with:
  ```
  postPatch = ''
    ...
    {
      echo -e '
        #undef  LUA_PATH_DEFAULT
        #define LUA_PATH_DEFAULT "./share/lua/${luaversion}/?.lua;./?.lua;./?/init.lua"
        #undef  LUA_CPATH_DEFAULT
        #define LUA_CPATH_DEFAULT "./lib/lua/${luaversion}/?.so;./?.so;./lib/lua/${luaversion}/loadall.so"
      '
    } >> src/luaconf.h
    ...
  '';
  ```
  hence by default, if you run any executable which links to this directory (`nvim` for example) from a directory which has folders `./lib/lua/` or `./share/lua` it will automatically find lua code and `.so` libraries in those folders.

### Lua environments

- Nixpgks allows you to build lua environments with the `withPackages` function in the various `lua-5*` attribute sets.

- A lua environment is just a derivation which gathers lua packages together. All the lua code from each package is inside `./share/lua/5.1/`, `.so` C libraries lua needs to link to are in `./lib/lua/5.1`, and all binaries of each package (typically only the `lua` interpreter or the `luajit` compiler) are put in `./bin`
  ```
  ▾ bin/
      lua* [RO]
      luajit* [RO]
      luajit-2.1.0-beta3* [RO]
  ▾ lib/
    ▾ lua/5.1/
        bit.so* -> /nix/store/yw82ssxj39f1ymww602sn5r4chkf0qg9-luajit2.1-luabitop-1.0.2-3/lib/lua/5.1/bit.so [RO]
        lpeg.so* -> /nix/store/cxy1dd7brlfwq5lixd5njh2k1i2659rh-luajit2.1-lpeg-1.0.2-1/lib/lua/5.1/lpeg.so [RO]
        mpack.so* -> /nix/store/6q1dnfnd0ggmxwk71p8rlcrncxgxnfsm-luajit2.1-mpack-1.0.9-0/lib/lua/5.1/mpack.so [RO]
    ▸ pkgconfig/ -> /nix/store/ldjanqzjxn68wyfnnxmqaa3sik945sr9-luajit-2.1.0-2022-10-04/lib/pkgconfig/
      libluajit-5.1.a -> /nix/store/ldjanqzjxn68wyfnnxmqaa3sik945sr9-luajit-2.1.0-2022-10-04/lib/libluajit-5.1.a [RO]
      libluajit-5.1.so* -> /nix/store/ldjanqzjxn68wyfnnxmqaa3sik945sr9-luajit-2.1.0-2022-10-04/lib/libluajit-5.1.so.2.1.0 [RO]
      libluajit-5.1.so.2* -> /nix/store/ldjanqzjxn68wyfnnxmqaa3sik945sr9-luajit-2.1.0-2022-10-04/lib/libluajit-5.1.so.2.1.0 [RO]
      libluajit-5.1.so.2.1.0* -> /nix/store/ldjanqzjxn68wyfnnxmqaa3sik945sr9-luajit-2.1.0-2022-10-04/lib/libluajit-5.1.so.2.1.0 [RO]
  ▾ share/
    ▾ lua/5.1/
      ▸ jit/ -> /nix/store/ldjanqzjxn68wyfnnxmqaa3sik945sr9-luajit-2.1.0-2022-10-04/share/lua/5.1/jit/
        re.lua -> /nix/store/cxy1dd7brlfwq5lixd5njh2k1i2659rh-luajit2.1-lpeg-1.0.2-1/share/lua/5.1/re.lua [RO]
  ```

- For all the binaries copied in `./bin`, they are wrapped such that the `LUA_PATH` and `LUA_CPATH` point to all the lua package in the environment. This ensures that lua code `require("xyz")` will resolve to the libs from each of these binaries (again typically this will be the `lua ` interpreter). This is done through generating a tiny C program which sets the `LUA_PATH` and `LUA_CPATH` environment variables and executes the original binary with `exec`. Check `lua-5/wrapper.nix`:
  ```
   postBuild = ''
     if [ -L "$out/bin" ]; then
         unlink "$out/bin"
     fi
     mkdir -p "$out/bin"

     addToLuaPath "$out"

     # take every binary from lua packages and put them into the env
     for path in ${lib.concatStringsSep " " paths}; do
       nix_debug "looking for binaries in path = $path"
       if [ -d "$path/bin" ]; then
         cd "$path/bin"
         for prg in *; do
           if [ -f "$prg" ]; then
             rm -f "$out/bin/$prg"
             if [ -x "$prg" ]; then
               nix_debug "Making wrapper $prg"
               makeWrapper "$path/bin/$prg" "$out/bin/$prg" \
                 --set-default LUA_PATH ";;" \
                 --suffix LUA_PATH ';' "$LUA_PATH" \
                 --set-default LUA_CPATH ";;" \
                 --suffix LUA_CPATH ';' "$LUA_CPATH" \
                 ${lib.concatStringsSep " " makeWrapperArgs}
             fi
           fi
         done
       fi
     done
   '' + postBuild;
  ```
  If you trace back `makeWrapper` it resolves to `build-support/setup-hooks/make-binary-wrapper/make-binary-wrapper.sh`, in which the C code is generated and compiled. In particular this line shows how the original executable is called:
  `main="${main}return execv(\"${executable}\", argv);"$'\n'`

- Example for a lua environment:
  ```
  store/aig7gndp8h0g6x77272zgm6hyxgvlrp2-luajit-2.1.0-2022-10-04-env/bin🔒
  ❯ ./lua
  LuaJIT 2.1.0-beta3 -- Copyright (C) 2005-2022 Mike Pall. https://luajit.org/
  JIT: ON SSE3 SSE4.1 BMI2 fold cse dce fwd dse narrow loop abc sink fuse
  > print(package.cpath)
  ;./lib/lua/5.1/?.so;./?.so;./lib/lua/5.1/loadall.so;;/nix/store/aig7gndp8h0g6x77272zgm6hyxgvlrp2-luajit-2.1.0-2022-10-04-env/lib/lua/5.1/?.so
  > print(package.path)
  ;./share/lua/5.1/?.lua;./?.lua;./?/init.lua;;/nix/store/aig7gndp8h0g6x77272zgm6hyxgvlrp2-luajit-2.1.0-2022-10-04-env/share/lua/5.1/?.lua;/nix/store/aig7gndp8h0g6x77272zgm6hyxgvlrp2-luajit-2.1.0-2022-10-04-env/share/lua/5.1/?/init.lua
  ```
  Also:
  ```
  readelf -p .rodata /nix/store/aig7gndp8h0g6x77272zgm6hyxgvlrp2-luajit-2.1.0-2022-10-04-env/bin/lua
  [    72]  setenv("LUA_PATH", ";;", 0)
  [    8e]  /nix/store/aig7gndp8h0g6x77272zgm6hyxgvlrp2-luajit-2.1.0-2022-10-04-env/share/lua/5.1/?.lua;/nix/store/aig7gndp8h0g6x77272zgm6hyxgvlrp2-luajit-2.1.0-2022-10-04-env/share/lua/5.1/?/init.lua
  [   14b]  LUA_CPATH
  [   155]  setenv("LUA_CPATH", ";;", 0)
  [   172]  /nix/store/aig7gndp8h0g6x77272zgm6hyxgvlrp2-luajit-2.1.0-2022-10-04-env/lib/lua/5.1/?.so
  [   1cb]  /nix/store/ldjanqzjxn68wyfnnxmqaa3sik945sr9-luajit-2.1.0-2022-10-04/bin/lua
  ```
  compare to the standalone lua binary package:
  ```
  /nix/store/ldjanqzjxn68wyfnnxmqaa3sik945sr9-luajit-2.1.0-2022-10-04🔒
  ❯ ./bin/lua
  LuaJIT 2.1.0-beta3 -- Copyright (C) 2005-2022 Mike Pall. https://luajit.org/
  JIT: ON SSE3 SSE4.1 BMI2 fold cse dce fwd dse narrow loop abc sink fuse
  > require("lpeg")
  stdin:1: module 'lpeg' not found:
          no field package.preload['lpeg']
          no file './share/lua/5.1/lpeg.lua'
          no file './lpeg.lua'
          no file './lpeg/init.lua'
          no file './lib/lua/5.1/lpeg.so'
          no file './lpeg.so'
          no file './lib/lua/5.1/loadall.so'
  stack traceback:
          [C]: in function 'require'
          stdin:1: in main chunk
          [C]: at 0x004062c0
  > print(package.path)
  ./share/lua/5.1/?.lua;./?.lua;./?/init.lua
  > print(package.cpath)
  ./lib/lua/5.1/?.so;./?.so;./lib/lua/5.1/loadall.so
  ```
  However launching the same executable from a directory with `lpeg` library available works:
  ```
  /nix/store/ldjanqzjxn68wyfnnxmqaa3sik945sr9-luajit-2.1.0-2022-10-04🔒 took 2h32m23s
  ❯ cd ../aig7gndp8h0g6x77272zgm6hyxgvlrp2-luajit-2.1.0-2022-10-04-env

  /nix/store/aig7gndp8h0g6x77272zgm6hyxgvlrp2-luajit-2.1.0-2022-10-04-env🔒
  ❯ ../ldjanqzjxn68wyfnnxmqaa3sik945sr9-luajit-2.1.0-2022-10-04/bin/lua
  LuaJIT 2.1.0-beta3 -- Copyright (C) 2005-2022 Mike Pall. https://luajit.org/
  JIT: ON SSE3 SSE4.1 BMI2 fold cse dce fwd dse narrow loop abc sink fuse
  > require("lpeg")
  ```

- The lua library defines a structure lua_State, on which you can "push" values, functions and have it execute lines of lua code

- You can define your own functions and push them in the environment. Here is an example from the official documentation to push a function called `mysin` into the environment (the lua state):
  ```
  # create an environment
  lua_State *L = lua_open();

  # define the function
  static int l_sin (lua_State *L) {
    double d = luaL_checknumber(L, 1);
    lua_pushnumber(L, sin(d)); # we use the standard sin function from the math C library here
    return 1;  /* number of results */
  }

  # push the function in the state
  lua_pushcfunction(L, l_sin);

  # create a global variable "mysin" referring to the function (I guess this works because this is called right after pushing the function on the lua Stack)
  lua_setglobal(L, "mysin");
  ```

- In nvim, for the "vim" object for example, the lua_State is built in `executor.c`. For instance for the `vim.loop` table, it is defined as so:
  ```
  luaopen_luv(lstate); # libluv is a library that binds libuv library to lua
  lua_pushvalue(lstate, -1);
  lua_setfield(lstate, -3, "loop");
  ```
