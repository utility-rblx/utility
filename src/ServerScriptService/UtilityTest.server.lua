local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Utility = require( ReplicatedStorage:WaitForChild('Utility'):WaitForChild('Utility') )

Utility:GetService('Http')

Utility:GetService('Http', 'HelloWorld')