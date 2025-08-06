-- TODO add an __index which launches the require
return {
  battery = require('my-tabline.components.battery'),
  current_working_directory = require('my-tabline.components.current-working-directory'),
  datetime = require('my-tabline.components.datetime'),
  domain = require('my-tabline.components.domain'),
  hostname = require('my-tabline.components.hostname'),
  invalid = require('my-tabline.components.invalid'),
  mode = require('my-tabline.components.mode'),
  window = require('my-tabline.components.window'),
  workspace = require('my-tabline.components.workspace'),
}
