local InstanceDungeons = {
  dungeons = {},
  dungeonInfos = {},

  validateinfo = {
		type = '', -- Leve this blank since this client and server can use this module.

		checks = { }
	}
}
setmetatable(InstanceDungeons.dungeons, {
  __index = function(t, k, v) 
    rawset(t, k, v)
    return t
  end -- If we try to index a dungeon tag which doesn't exist
})

InstanceDungeons.__index = InstanceDungeons

function InstanceDungeons:AddBoundingBoxes(dungeons: { Model }): { Model }
  for _, model in pairs(dungeons) do
    if model.PrimaryPart == 'Box' then continue end

    local position, size = model:GetBoundingBox()
    local box = Instance.new('Part')

    box.Name = 'BoundingBox'

    box.Transparency = 1
    box.Anchored = true
    box.CanCollide = false
    
    box.Size = size
    box.Position = position.Position

    box.Touched:Connect(function() end) -- this can fix the CanCollide issue when trying to get the parts inside of this box

    box.Parent = model
    model.PrimaryPart = box
  end

  return dungeons
end

function InstanceDungeons:CalculateOffsets(dungeons: { Model }): { Vector3 }
  local offsets: { Vector3 } = {}

  for _, model in pairs(dungeons) do
    offsets[model] = model.PrimaryPart.Size
  end

  return offsets
end

function InstanceDungeons:Distances(dungeons: { Model }, offset: number): { number }
  local distances: { number } = {}
  local count = 0

  for index, model in pairs(dungeons) do
    distances[index] = count
    count += model.PrimaryPart.Size.Z

    print(count)
  end

  return distances
end

-- Exports
export type Settings = {
  StartingPosition: Vector3?,
  Offset: number?,
  DungeonsFolder: Folder?
}?

-- InstanceDungeons
function InstanceDungeons.makedungeon(dungeonTag: string, dungeons: { Model }, party: { Player }, settings: Settings): nil -- We are going to use a list of models since they contain Model:GetBoundingBox, which is really useful.
  local new_instance: { any } = {}
  local self = setmetatable(new_instance, {})

  settings = settings or {}

  self.Dungeons = InstanceDungeons:AddBoundingBoxes(dungeons)
  self.Offsets = InstanceDungeons:CalculateOffsets(dungeons)
  self.Distances = InstanceDungeons:Distances(dungeons, 0)
  self.Players = party

  self.AllDungeons = InstanceDungeons.dungeons[dungeonTag]

  self.StartingPosition = settings.StartingPosition or Vector3.new(0,0,0)
  self.SpawnOffset = settings.Offset or 1
  self.DungeonFolder = settings.DungeonsFolder or workspace

  InstanceDungeons.dungeonInfos[dungeonTag] = new_instance

  return
end

function InstanceDungeons.loaddungeon(dungeonTag: string): any
  local new_dungeon: { any } = InstanceDungeons.dungeonInfos[dungeonTag]
  local self = setmetatable(new_dungeon, InstanceDungeons)

  self.ReservedPosition = #self.AllDungeons
  self.ActiveDungeons = {}

  table.insert(self.AllDungeons, {
    party = self.Players
  })
  
  return new_dungeon
end

function InstanceDungeons:SpawnDungeon(dungeon: number): Model
  if self.ActiveDungeons[dungeon] then return self.ActiveDungeons[dungeon] end

  local dungeonModel = self.Dungeons[dungeon]
  local new_dungeon_model: Model = dungeonModel:Clone()
  local offsets = self.Offsets[dungeonModel]

  self.ActiveDungeons[dungeon] = new_dungeon_model

  -- X: Each Dungeon Instance | Y: Nil | Z: Each Dungeon Part
  local newPosition = Vector3.new(
    self.StartingPosition.X + (offsets.X * self.ReservedPosition) + (self.SpawnOffset * self.ReservedPosition),
    self.StartingPosition.Y,
    self.Distances[dungeon]
  )

  print(self.ReservedPosition)

  new_dungeon_model:SetPrimaryPartCFrame( CFrame.new( newPosition ) )
  new_dungeon_model.Parent = self.DungeonFolder

  return new_dungeon_model
end

function InstanceDungeons:DespawnDungeon(dungeon: number): nil
  local dungeon_model = self.ActiveDungeons[dungeon]

  assert( dungeon_model, ('Cannot find %i in ActiveDungeons.'):format(dungeon) )

  dungeon_model:Destroy()

  self.ActiveDungeons[dungeon] = nil

  return 
end

return InstanceDungeons