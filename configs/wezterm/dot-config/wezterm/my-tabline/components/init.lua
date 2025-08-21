local function make_factory(select)
  return setmetatable({}, {
    __index = function(_, component_name)
      local component_exists, component_builders = pcall(require, 'my-tabline.components.' .. component_name)
      if component_exists then
        return select(component_builders)
      end
      return select(require('my-tabline.components.invalid'))
    end
  })
end

return {
  for_window = make_factory(function(component_builders) return component_builders.for_window end),
  for_tab = make_factory(function(component_builders) return component_builders.for_tab end),
}
