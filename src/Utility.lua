local Utility = {}

local RunService = game:GetService('RunService')

local UtilityFolder = script.Parent
local Data = require( UtilityFolder:WaitForChild('Data') )

local Services = UtilityFolder:WaitForChild('Services')
local Sub_Services = UtilityFolder:WaitForChild('Sub-Services')

-- Types
export type ValidateData = {
  type: string,
  checks: {{ 
      check_function: (... any) -> any,
      fail_msg: string
  }}
}

export type ServiceData = {
  validateinfo: ValidateData,
}

-- Functions
function Utility:Validate(validateData: ValidateData): boolean
  local scriptType: string = Data.ScriptTypes[ validateData.type ]

  -- Check Script Type
  if scriptType then
    assert( 
      RunService[scriptType](RunService),
      ('This is a %s module only'):format(validateData.type)
    )
  end

  -- Checks
  for _, check_data in pairs(validateData.checks) do
    assert(
      check_data.check_function(),
      check_data.fail_msg
    )
  end

  return true
end

function Utility:GetFile(service: string, sub_service: string? ): ModuleScript
  local file: ModuleScript = (sub_service and true) and
    Sub_Services:FindFirstChild(service):FindFirstChild(sub_service) or
    Services:FindFirstChild(service)  

  assert(
    file,
    ('Could not find service: %s | sub-service: %s'):format( service, tostring(sub_service) )
  )

  return file
end

function Utility:GetServiceData( service: string, sub_service: string? ): { any }
  local servicefile = Utility:GetFile(service, sub_service)
  return require(servicefile)
end

function Utility:GetService( service: string, sub_service: string? ): { any }
  local servicedata = Utility:GetServiceData(service, sub_service)
  
  Utility:Validate(servicedata.validateinfo) -- Will error if fails

  return servicedata
end

function Utility:GetServiceWithoutValidate( service: string, sub_service: string? ): { any }
  return Utility:GetServiceData(service, sub_service)
end

return Utility