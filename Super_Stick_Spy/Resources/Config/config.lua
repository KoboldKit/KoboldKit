
--[[

This script contains global settings. 

Config.lua is shared with other developers. For machine or developer specific settings use devconfig.lua.

--]]

local config =
{
	Audio = {
		SFXVolume = 1.0,
		MusicVolume = 0.5,
		SpeechVolume = 1.0,
	},
	Player = {
		JumpForce = 200,
		MaxVelocity = 125,
	},
	Credits = {
		["Project Management"] = "Hans Gruber",
		["Design & Dilemmas"] = "Hannibal Lecter",
		["Code & Asskicking"] = "Chuck Norris",
		["Art & Weirdness"] = "Tim Burton",
	}
}

return config
