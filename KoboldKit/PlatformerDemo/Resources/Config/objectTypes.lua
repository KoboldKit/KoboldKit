-- objectTypes.lua
-- Defines names of objects in Tileds to determine which ObjC classes to create
-- and which properties/ivars to set on these classes.

local kContactCategoryPlayer = 1
local kContactCategoryPickupItem = 2

local objectTypes =
{
	SpriteNode =
	{
		className = "SKSpriteNode",
		properties =
		{
			imageName = "MissingResource.png",
		},
	},

	LabelNode =
	{
		className = "SKLabelNode",
		properties =
		{
			fontName = "Arial",
			fontSize = 10,
			fontColor = {color = "1.0 0.0 1.0 1.0"}, -- color = "R G B A"
			text = "<missing text>",
		},
	},

	Player =
	{
		-- used by Tiled (needs simple tool to convert to Tiled objectdef.xml format)
		tiledColor = "#ff0055", 
		-- create an instance of this class (class must inherit from SKNode or its subclasses)
		className = "PlayerCharacter",
		
		-- optional: use a custom init method with default params
		--init = {"spriteWithColor:size:", "{200, 0, 0}", "{240, 120}"},
		
		properties =
		{
			_fallSpeedAcceleration = 50, -- how fast player accelerates when falling down
			_fallSpeedLimit = 250,			-- max falling speed
			_jumpAbortVelocity = 150,		-- the (max) upwards velocity forcibly set when jump is aborted
			_jumpSpeedInitial = 500,		-- how fast the player initially moves upwards when jumping is initiated
			_jumpSpeedDeceleration = 20,	-- how fast upwards motion (caused by jumping) decelerates
			_runSpeedAcceleration = 0,		-- how fast player accelerates sideways (0 = instant)
			_runSpeedDeceleration = 0,		-- how fast player decelerates sideways (0 = instant)
			_runSpeedLimit = 200,			-- max sideways running speed
			
			_defaultImage = "Dummy_Player_32.png",
		},
		
		-- physics body properties
		physicsBody =
		{
			shapeType = "rectangle",
			shapeSize = "{32, 36}",
			
			properties =
			{
				allowsRotation = NO,
				mass = 0.33,
				restitution = 0.04,
				linearDamping = 0,
				angularDamping = 0,
				friction = 0,
				affectedByGravity = NO,
				categoryBitMask = kContactCategoryPlayer,
				contactTestBitMask = 0, --kContactCategoryPlayer + kContactCategoryPickupItem,
				collisionBitMask = 0xffffffff - kContactCategoryPickupItem,
			},
		},
		
		behaviors =
		{
			--{behaviorClass = "KKLimitVelocityBehavior", properties = {velocityLimit = 100}},
			{className = "KKStayInBoundsBehavior", properties = {bounds = "{{0, 0}, {0, 0}}"}},
			{className = "KKCameraFollowBehavior"},
			--{className = "KKPickupItemCollectorBehavior"},
		},
		
		actions =
		{
			-- not yet supported
		},
	},

	PickupItem =
	{
		inheritsFrom = "SpriteNode",
		physicsBody =
		{
			shapeType = "rectangle",
			shapeSize = "{10, 10}",
			properties =
			{
				categoryBitMask = kContactCategoryPickupItem,
				contactTestBitMask = kContactCategoryPlayer,
				collisionBitMask = 0,
				affectedByGravity = NO,
				dynamic = YES,
			},
		},
		behaviors =
		{
			--{className = "KKRemoveOnContactBehavior"}, -- physics contact resolves in a remove of this node
			--{className = "KKPickupItemBehavior"}, -- remove of this node sends message to KKPickupItemCollectorBehavior
		},
	},
	
	Briefcase =
	{
		inheritsFrom = "PickupItem",
	},
}

return objectTypes
