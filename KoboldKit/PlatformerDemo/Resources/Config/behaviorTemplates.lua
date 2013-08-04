-- behaviorTemplates.lua
-- Behavior templates define one or more behaviors that can be added to a node in Tiled by string reference.
-- The behavior's properties are taken from Tiled's properties using the template name as prefix.
-- For example:
-- FollowPath.speed will set the speed property of the FollowPath behavior

local behaviorTemplates =
{
	FollowPath =
	{
		className = "KKFollowPathBehavior",
		properties = 
		{
			pathName = "<missing path>",	-- name of path object
			moveSpeed = 2,					-- movement speed in points per frame
			--repeatCount = 1,				-- 0 == repeat indefinitely, for polylines 1 == move to end, 2 == move to end and back to start
			--waypointWaitDuration = 0,
			--initialWaitDuration = 0,
		},
	},
}

return behaviorTemplates
