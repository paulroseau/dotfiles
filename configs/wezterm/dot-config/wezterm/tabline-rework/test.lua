Section = {}

Section.toto = 'hello'

function Section.new(self, _args)
  local instance = _args or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

x = Section:new({ x = 1 })

Section.foo = 'bar'

a = Section:new({ x = 1 })
b = Section.new(a, { y = 2 })


-- left = {
--   sections = {
--    background
--    default_foreground
--    attribute (bold/italic)
--    component_separator
--    icon_only
--    text_only
--    components = {
--      {
--        icon = Option { Option(foreground), value }
--        text = Option { Option(foreground), value }
--        padding = { left, right }
--      }
--    }
--    section_separator = str
--  }
--
-- right = (like left)
--


local Component = {
  padding_left = 0,
  padding_right = 0,
}

function Component:new(_args)
  local instance = _args or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

a = Component:new({ padding_left = 1 })
