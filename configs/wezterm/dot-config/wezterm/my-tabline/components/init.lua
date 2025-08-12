local components_for_window = setmetatable({}, {
  __index = function(_, component_name)
    local component_exists, component = pcall(require, 'my-tabline.components.' .. component_name)
    if component_exists then
      return component.for_window
    end
    return require('my-tabline.components.invalid').for_window
  end
})

local components_for_tab = setmetatable({}, {
  __index = function(_, component_name)
    local component_exists, component = pcall(require, 'my-tabline.components.' .. component_name)
    if component_exists then
      return component.for_tab
    end
    return require('my-tabline.components.invalid').for_tab
  end
})

return {
  for_window = components_for_window,
  for_tab = components_for_tab,
}
