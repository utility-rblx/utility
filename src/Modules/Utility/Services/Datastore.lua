local DataStoreService = game:GetService('DataStoreService')

local Datastore = {
  loaded_datastores = {},

	validateinfo = {
		type = 'server',

		checks = {  } -- TODO: Find a way to check if the datastores are enabled
	}
}
Datastore.__index = Datastore
setmetatable(Datastore.loaded_datastores, { __index = function(t, k, v) rawset(t, k, v) end })

-- Exports
export type Settings = {
  DataTemplate: any?,
  FallbackDataTemplate: any?
}?

export type AsyncData = {
  success: boolean,
  data: any
}

-- Main
function Datastore.new(datastore: string, settings: Settings): any
  local new_store = {}
  local self = setmetatable(new_store, Datastore)

  settings = settings or {}

  self.Datastore = DataStoreService:GetDataStore(datastore)

  self.DataTemplate = settings.DataTemplate
  self.FallbackDataTemplate = settings.FallbackDataTemplate

  self.DatastoreDatas = Datastore.loaded_datastores[datastore]

  return new_store
end

-- Main/Primary
function Datastore:GetAsync(key: string): AsyncData
  local success, data = pcall(self.Datastore.GetAsync, self.Datastore, key)

  return {
    success = success,
    data = data
  }
end

function Datastore:SetAsync(key: string, value: any): AsyncData
  local success, data = pcall(self.Datastore.SetAsync, self.Datastore, key, value)

  return {
    success = success,
    data = data
  }
end

-- Main/Methods
function Datastore:FixData(data: any): nil

  return
end

function Datastore:LoadData(key: string): any
  local data = self:GetAsync(key)

  if not data.success then return false end

  local new_data = {}
  local data_self = setmetatable(new_data, self.DatastoreDatas[key])
  self.DatastoreDatas.__index = self.DatastoreDatas

  data_self.Data = data.data

  return new_data
end