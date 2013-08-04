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
			moveSpeed = 10,					-- movement speed in points per frame
			relativeToObject = NO,			-- if YES, object will follow path but with object's current position as offset
			orientToPath = NO,				-- if YES, object will rotate in direction of current path segment
			initialWaitDuration = 0,		-- start follow immediately (time in seconds)
			repeatCount = 0,					-- 0 == repeat indefinitely, for polylines 1 == move to end, 2 == move to end and back to start
			
			--waypointWaitDuration = 0,
		},
	},
}

return behaviorTemplates
