local function all_available_components(select_builder)
  return setmetatable({}, {
    __index = function(_, component_name)
      local component_builder = nil
      local component_exists, component_builders = pcall(require, 'my-tabline.components.' .. component_name)
      if component_exists then
        component_builder = select_builder(component_builders)
      end
      return component_builder or select_builder(require('my-tabline.components.invalid'))
    end
  })
end

local function select_builder_for_window(component_builders)
  return component_builders.for_window
end

local function select_builder_for_tab(component_builders)
  return component_builders.for_tab
end

return {
  for_window = function(gui_window, pane)
    return function(component_name)
      local all_window_components = all_available_components(select_builder_for_window)
      local component = all_window_components[component_name]
      return component(gui_window, pane)
    end
  end,
  for_tab = function(tab_info)
    return function(component_name)
      local all_tab_components = all_available_components(select_builder_for_tab)
      local component = all_tab_components[component_name]
      return component(tab_info)
    end
  end,
}
