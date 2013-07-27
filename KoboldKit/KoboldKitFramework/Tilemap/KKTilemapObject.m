//
// KTTilemapObject.m
// KoboldTouch-Libraries
//
// Created by Steffen Itterheim on 20.12.12.
//
//

#import "KKTilemapObject.h"
#import "KKTilemapProperties.h"
#import "KKTypes.h"

@implementation KKTilemapObject

-(NSString*) description
{
	return [NSString stringWithFormat:@"%@ (name: '%@', userType: '%@', position: %.0f,%.0f, type: %i, properties: %u)",
			[super description], _name, _type, _position.x, _position.y, _objectType, (unsigned int)_properties.count];
}

-(KKTilemapProperties*) properties
{
	if (_properties == nil)
	{
		_properties = [[KKTilemapProperties alloc] init];
	}

	return _properties;
}

-(KKTilemapRectangleObject*) rectangleObjectFromPolyObject:(KKTilemapPolyObject*)polyObject
{
	KKTilemapRectangleObject* rectObject = [[KKTilemapRectangleObject alloc] init];
	rectObject.name = polyObject.name;
	rectObject.type = polyObject.type;
	rectObject.position = polyObject.position;
	[rectObject internal_setProperties:polyObject.properties];
	rectObject.size = CGSizeZero;
	return rectObject;
}

-(void) internal_setProperties:(KKTilemapProperties*)properties
{
	_properties = properties;
}

@end

@implementation KKTilemapPolyObject

-(id) init
{
	self = [super init];
	if (self)
	{
		self.objectType = KKTilemapObjectTypePolyLine;
		_points = nil;
	}

	return self;
}

-(void) makePointsFromString:(NSString*)string
{
	NSArray* pointStrings = [string componentsSeparatedByString:@" "];

	_boundingBox = CGRectZero;
	_numberOfPoints = (unsigned int)pointStrings.count;
	_points = realloc(_points, _numberOfPoints * sizeof(CGPoint));

	NSUInteger currentIndex = 0;
	for (NSString* pointString in pointStrings)
	{
		// damn CGPointFromString requires the format with brackets, NSPointFromString happily converts without brackets
		// converting the input string for both platforms to the correct format with brackets, just in case
		CGPoint point = pointFromString([NSString stringWithFormat:@"{%@}", pointString]);
		point.y *= -1.0f;
		_points[currentIndex++] = point;
	}

	[self updateBoundingBox];
} /* makePointsFromString */

-(void) updateBoundingBox
{
	CGPoint boundingBoxBottomLeft = CGPointZero;
	CGPoint boundingBoxTopRight = CGPointZero;

	for (unsigned int i = 0; i < _numberOfPoints; i++)
	{
		CGPoint point = _points[i];
		boundingBoxBottomLeft.x = MIN(point.x, boundingBoxBottomLeft.x);
		boundingBoxBottomLeft.y = MIN(point.y, boundingBoxBottomLeft.y);
		boundingBoxTopRight.x = MAX(point.x, boundingBoxTopRight.x);
		boundingBoxTopRight.y = MAX(point.y, boundingBoxTopRight.y);
	}

	_boundingBox = CGRectMake(boundingBoxBottomLeft.x, boundingBoxBottomLeft.y, boundingBoxTopRight.x, boundingBoxTopRight.y);
	_boundingBox.size = CGSizeMake(boundingBoxTopRight.x - _boundingBox.origin.x, boundingBoxTopRight.y - _boundingBox.origin.y);
	_boundingBox.origin = ccpAdd(_position, _boundingBox.origin);
} /* updateBoundingBox */

-(void) dealloc
{
	free(_points);
}

@end

@implementation KKTilemapRectangleObject

-(id) init
{
	self = [super init];
	if (self)
	{
		self.objectType = KKTilemapObjectTypeRectangle;
	}

	return self;
}

@dynamic rect;
-(CGRect) rect
{
	return CGRectMake(_position.x, _position.y, _size.width, _size.height);
}

@end

@implementation KKTilemapTileObject

-(id) init
{
	self = [super init];
	if (self)
	{
		self.objectType = KKTilemapObjectTypeTile;
	}

	return self;
}

@end

