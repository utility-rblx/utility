local HttpsService = game:GetService('HttpService')

local Http = {
	Properties = {},
	Methods = {},
	
	validateinfo = {
		type = 'server',

		checks = { {
			check_function = function() return pcall(HttpsService.GetAsync, HttpsService, 'https://google.com/') end,
			fail_msg = 'You need to have HttpService enabled in this experence.'
		} }
	}
}
Http.__index = Http

return Http