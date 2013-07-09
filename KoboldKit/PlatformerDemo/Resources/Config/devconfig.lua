--[[

This script contains developer settings. 

IMPORTANT:
- The file must be copied and renamed from devconfig.lua.sample to devconfig.lua
- The devconfig.lua *must not be checked in* to source control

devconfig.lua should not be shared with other developers, use config.lua for settings to be shared with other developers.
devconfig.lua should not be used for settings that will be used by the published app. It is only for development settings.

--]]

local config =
{
	developmentWebServerURL = "http://10.0.0.8:32111",

	showsFPS = YES,
	showsDrawCount = YES,
	showsNodeCount = YES,
	showsPhysicsShapes = NO,
}

return config
