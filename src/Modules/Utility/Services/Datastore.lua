local DataStoreService = game:GetService('DataStoreService')
local Players = game:GetService('Players')

local Datastore = {
  settings = {},

  datas = {},

	validateinfo = {
		type = 'server',

		checks = {  } -- TODO: Find a way to check if the datastores are enabled
	}
}
Datastore.__index = Datastore
setmetatable(Datastore.datas, { __index = function(t, k, v) rawset(t, k, v) end })

function Datastore.settings.new(): any
  local new_settings = {}
  local self = setmetatable(new_settings, Datastore.settings)

  return new_settings
end

function Datastore.new(datastore: string, template: { any }): any
  local new_datastore = {}
  local self = setmetatable(new_datastore, Datastore)

  self.Datastore = DataStoreService:GetDataStore(datastore)

  self.Storage = Datastore.datas[datastore]

  self.Template = template

  return new_datastore
end

function Datastore:GetData(key: string): any
  print(Datastore.datas)
end