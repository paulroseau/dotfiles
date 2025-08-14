local function make_factory(select)
  return setmetatable({}, {
    __index = function(_, component_name)
      local component_exists, make_component_functions = pcall(require, 'my-tabline.components.' .. component_name)
      if component_exists then
        return select(make_component_functions)
      end
      return select(require('my-tabline.components.invalid'))
    end
  })
end

local function select_for_window(make_component_functions)
  return function(args)
    return make_component_functions.for_window(args.window, args.pane)
  end
end

local function select_for_tab(make_component_functions)
  return function(args)
    return make_component_functions.for_tab(args.tab_info)
  end
end

return {
  for_window = make_factory(select_for_window),
  for_tab = make_factory(select_for_tab)
}
