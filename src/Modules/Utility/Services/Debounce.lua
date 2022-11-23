local Debounce = {
  validateinfo = {
		type = '', -- Leve this blank since this client and server can use this module.

		checks = { }
	}
}
Debounce.__index = Debounce

-- Exports
export type Settings = {
  delay: number?,
  coroutine: boolean?
}

-- Debounce
function Debounce.new(debounce_function: (... any) -> any, settings: Settings): any
  local new_debounce: { any } = {}
  local self = setmetatable(new_debounce, Debounce)

  settings = settings or {}

  self.Delay = settings.delay or 0
  self.Coroutine = settings.coroutine or false

  self.DebounceFunction = self.Coroutine and coroutine.wrap(debounce_function) or debounce_function
  self.Debounced = false

  return new_debounce
end

function Debounce.wrap(debounce_function: (... any) -> any, delay: number): (... any) -> any
  local new_debounce = Debounce.new(debounce_function, {
    delay = delay
  })

  return function(...) new_debounce:Run(...) end
end

function Debounce:Run(...): nil
  local args: { any } = { ... }

  if self.Debounced then return end

  self.Debounced = true
  self.DebounceFunction( table.unpack(args) ); task.wait(self.Delay)
  self.Debounced = false

  return
end

function Debounce:TempRun(...): nil
  self.Debounced = true -- making it locked
  self.DebounceFunction(...)
  return
end

function Debounce:RawRun(...): nil
  self.DebounceFunction(...)
  return
end

return Debounce