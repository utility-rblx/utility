local HttpsService = game:GetService('HttpService')

local Http = {
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

-- Methods
function Http.Methods:GenerateGUID(wrapped: boolean?): string
	return HttpsService:GenerateGUID(wrapped)
end

function Http.Methods:EncodeJSON(list: { any }): string
	return HttpsService:JSONEncode(list)
end

function Http.Methods:DecodeJSON(JSONstring: string): { any }
	return HttpsService:JSONDecode(JSONstring)
end

function Http.Methods:EncodeURL(...): { string }
	local data: { any } = { ... }
	local result: { string } = {}

	for _, string in pairs(data) do
		table.insert( result, HttpsService:UrlEncode(string) )
	end

	return result
end

function Http.Methods:EncodeList2URL(data: { any }): string
	local result: { any } = {}
	local format = '%s=%s'

	for key, value in pairs(data) do
		local encoded: { string } = Http.Methods:EncodeURL( key, value )

		table.insert(
			result,
			format:format( encoded[1], encoded[2] )
		)
	end

	return table.concat(result, '&')
end

-- Exports
export type GetAsyncData = {
	nocache: boolean?,
	headers: { any }?
}

export type PostAsyncData = {
	data: any,
	content_type: Enum.HttpContentType?, -- Unsure if its a Enum.HttpContentType or something else
	compress: boolean?,
	headers: { any }?
}

export type HttpSettings = {
	GetAsync: GetAsyncData?,
	PostAsync: PostAsyncData?
}?

export type AsyncData = {
	success: boolean,
	data: string
}

-- Http
function Http.new(URL: string, settings: HttpSettings): any
	local new_request: { any } = {}
	local self = setmetatable(new_request, Http)
	
	settings = settings or {}

	self.URL = URL

	self.GetAsyncData = settings.GetAsync or {}
	self.PostAsyncData = settings.PostAsync or {}

	return new_request
end

function Http:GetAsync(settings: GetAsyncData?): AsyncData
	settings = settings or self.GetAsyncData

	local success, data = pcall( HttpsService.GetAsync, HttpsService, self.URL,
		settings.nocache,
		settings.headers
	)

	print(settings.headers)

	return {
		success = success,
		data = data
	}
end

function Http:PostAsync(settings: PostAsyncData?): AsyncData
	settings = settings or self.PostAsyncData

	local success, data = pcall( HttpsService.PostAsync, HttpsService, self.URL,
		settings.data,
		settings.content_type,
		settings.compress,
		settings.headers
	)

	return {
		success = success,
		data = data
	}
end

function Http:GetAsyncAPI(settings: GetAsyncData?): { any } | nil
	local data = self:GetAsync(settings)

	if not data.success then
		warn( ('Unable to GetAsync: %s. Error: %s'):format(self.URL, tostring(data.data)) )
		return
	end

	return Http.Methods:DecodeJSON(data.data)
end

function Http:PostAsyncAPI_URLEncoded(data: { any }): AsyncData
	local encodedURList = Http.Methods:EncodeList2URL(data)

	return self:PostAsync({
		data = encodedURList,
		content_type = Enum.HttpContentType.ApplicationJson,
		compess = false,
		headers = nil
	})
end

function Http:PostAsyncAPI_JSONEncoded(data: { any }): AsyncData
	local encodedJSONList = Http.Methods:EncodeJSON(data)

	return self:PostAsync({
		data = encodedJSONList,
		content_type = Enum.HttpContentType.ApplicationJson,
		compess = false,
		headers = nil
	})
end

return Http