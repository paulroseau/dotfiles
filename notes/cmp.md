# nvim-cmp

The architecture relies on sources, which need to implement a particular interface. If you look into the `nvim-cmp/lua/source.lua` source, you will see a source is created by passing around a `s` which will be assigned to `self.source`. `s` must implement a series of function, in particular `complete`. Some are optional since `nvim-cmp` calls them with an `if` in front:
```lua
source.is_available = function(self)
  if self.source.is_available then
    return self.source:is_available()
  end
  return true
end
```

All `cmp-*` plugins which implement a source, register themselves as an
available sources in their `./after` directory:
```lua
require('cmp').register_source('path', require('cmp_path').new())
```

That means `nvim-cmp` needs to be in the runtimepath.

For mappings, you can specify if a mapping should be active in insert mode or command mode (for `:` and `/`).

The `config` object has a `__call` meta methods which resolves to setting the value passed as a field of that object through doing some checks via the normalize function. Also some utility methods are mapped to it such as `set_cmdline` which allows to set configuration for a particular type of cmdline (`:`, `/`) for example.
