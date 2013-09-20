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
	-- these values are recognized and used
	developmentWebServerURL = "http://10.0.0.8:32111",

	-- quickly turn on/off the debug labels without having to change the individual flags below
	disableAllDebugLabels = NO,

	-- common Sprite Kit labels
	showsFPS = YES,
	showsDrawCount = YES,
	showsNodeCount = YES,

	-- private Sprite Kit labels
	showsCoreAnimationFPS = YES,
	showsCPUStats = YES,
	showsGPUStats = YES,
	showsCulledNodesInNodeCount = NO,
	showsTotalAreaRendered = NO,
	showsSpriteBounds = NO,
	shouldCenterStats = NO,

	-- additional Kobold Kit labels
	showsPhysicsShapes = NO,
	showsNodeFrames = NO,
	showsNodeAnchorPoints = NO,
}

return config
